// pellet-meter — ciclo: risveglio, misura, advertising BTHome, deep sleep.
//
// Lo scheletro del ciclo e' completo e l'ordine delle fasi e' deliberato
// (vedi sotto); i blocchi di acquisizione e di radio sono i task ancora
// aperti del change OpenSpec 'firmware-bthome', marcati con TODO e il
// numero del task.

#include <inttypes.h>
#include <stdio.h>

#include "esp_attr.h"
#include "esp_log.h"
#include "esp_sleep.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

#include "pins.h"

static const char *TAG = "pellet-meter";

// Il deep sleep taglia la USB Serial/JTAG a meta' frase, e si finisce a
// cercare un guasto dentro un messaggio troncato. Questa attesa serve solo
// a chi guarda il log: va messa a 0 quando il dispositivo e' in funzione,
// perche' e' tempo di CPU sveglia pagato a ogni ciclo.
#define LOG_FLUSH_MS 20

// Intervallo di risveglio: 10 minuti. La ragione della scelta e il criterio
// per cambiarlo stanno in docs/, pagina Firmware. In breve: il livello del
// pellet cambia lentamente, e 600 s stanno sotto i 900 s oltre i quali Home
// Assistant considera scaduto un advertisement.
#define WAKEUP_INTERVAL_S 600

// Il packet id sopravvive al deep sleep in RTC memory: e' l'unica memoria
// che non usura la flash. Al primo avvio (power-on) parte da zero.
static RTC_DATA_ATTR uint8_t packet_id;

// Accende o spegne il breakout del sensore.
//
// ATTENZIONE: alto = acceso. Con l'upgrade a P-MOSFET high-side annotato
// sullo schema la logica si inverte; il punto da cambiare e' questo piu'
// il commento su PIN_VSENS.
static void sensor_power_set(bool on)
{
    gpio_config_t cfg = {
        .pin_bit_mask = 1ULL << PIN_VSENS,
        .mode = GPIO_MODE_OUTPUT,
    };
    ESP_ERROR_CHECK(gpio_config(&cfg));
    ESP_ERROR_CHECK(gpio_set_level(PIN_VSENS, on ? 1 : 0));
}

// Imposta lo switch RF dell'antenna.
//
// Va chiamata a ogni risveglio e PRIMA di inizializzare il BLE: i due GPIO
// non sono LP/RTC, quindi dopo il deep sleep sono in alta impedenza e lo
// switch non e' comandato. Saltare questo passo non da' errori: l'unico
// sintomo e' un advertising attenuato, che si manifesta come "Home
// Assistant a volte non lo vede".
static void rf_switch_init(void)
{
    gpio_config_t cfg = {
        .pin_bit_mask = (1ULL << PIN_RF_SWITCH_EN) | (1ULL << PIN_RF_ANT_SEL),
        .mode = GPIO_MODE_OUTPUT,
    };
    ESP_ERROR_CHECK(gpio_config(&cfg));

    // Basso abilita il controllo dello switch; va fatto prima di scegliere
    // l'antenna.
    ESP_ERROR_CHECK(gpio_set_level(PIN_RF_SWITCH_EN, 0));
    ESP_ERROR_CHECK(gpio_set_level(PIN_RF_ANT_SEL, RF_ANT_SEL_LEVEL));
}

void app_main(void)
{
    ESP_LOGI(TAG, "risveglio, packet id %" PRIu8, packet_id);

    // L'ordine delle prime due fasi non e' casuale. Il sensore ha bisogno di
    // qualche millisecondo per avviarsi dopo che gli arriva corrente, e lo
    // switch RF ha bisogno di assestarsi: accendendo prima il sensore, le
    // due attese si sovrappongono invece di sommarsi.
    sensor_power_set(true);
    rf_switch_init();

    // L'esempio Seeed mette 100 ms di attesa dopo aver comandato lo switch.
    // Non e' gratis: 100 ms per ciclo sono ~14 s al giorno di CPU sveglia,
    // una frazione non trascurabile del budget. Resta cosi' finche' non si
    // misura quanto serve davvero.
    vTaskDelay(pdMS_TO_TICKS(100));

    // TODO task 3.1-3.3: init VL53L1X su I2C, mediana di 5-7 misure,
    // scartando le letture non valide. Se non resta nessuna lettura valida
    // la distanza non va nel pacchetto: non si inventa un numero.

    // TODO task 3.4-3.6: lettura del partitore con ADC calibrato. Il nodo ha
    // impedenza alta (500 kOhm) e C1 da 100 nF: va lasciato stabilizzare
    // prima di campionare.

    // TODO task 2.3-2.4: pacchetto BTHome v2 (device info 0x44, oggetti in
    // ordine crescente di ID) e advertising per ~1 s.

    // TODO task 4.2: stato sicuro di SDA/SCL/XSHUT. Finche' non c'e' nulla
    // che tocchi quelle linee non c'e' niente da riportare a posto, ma
    // l'ordine giusto e' questo: prima le linee, poi l'alimentazione.
    sensor_power_set(false);

    packet_id++;

    ESP_LOGI(TAG, "dormo %d s", WAKEUP_INTERVAL_S);
    fflush(stdout);
    if (LOG_FLUSH_MS > 0) {
        vTaskDelay(pdMS_TO_TICKS(LOG_FLUSH_MS));
    }

    ESP_ERROR_CHECK(esp_sleep_enable_timer_wakeup(
        (uint64_t)WAKEUP_INTERVAL_S * 1000000ULL));
    esp_deep_sleep_start();
}
