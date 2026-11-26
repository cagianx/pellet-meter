// Mappa dei pin. Lo XIAO ESP32C6 stampa sulla scheda i nomi D0..D10, che
// non sono i numeri di GPIO: tradurli a mano in ogni file e' il modo di
// sbagliarne uno. Qui stanno entrambi i nomi, e questa e' l'unica tabella.
//
// Corrispondenza D -> GPIO dal wiki Seeed del XIAO ESP32C6; le reti sono
// quelle dello schema in kicad/pellet-meter.kicad_sch.

#pragma once

#include "driver/gpio.h"
#include "hal/adc_types.h"

// --- Reti dello schema ------------------------------------------------------

// SENS_CTRL: il pin che comanda l'alimentazione del breakout VL53L1X.
#define PIN_SENS_CTRL GPIO_NUM_2 // D2

// Come e' alimentato il sensore. Sul PCB le due configurazioni convivono e
// si scelgono col ponticello JP1 (1-2 diretta, 2-3 a MOSFET); su millefori
// c'e' solo la diretta.
//
//   0  diretta: D2 alimenta il breakout. ALTO = acceso.
//   1  MOSFET:  D2 pilota il gate di Q1, P-MOSFET high-side. BASSO = acceso.
//
// FRA LE DUE LA LOGICA SI INVERTE. E' una scelta esplicita a compile time
// proprio per questo: montare Q1 e dimenticarsene produce un sensore che
// non si accende mai, e sul banco sembra un sensore guasto. Il default e'
// allineato al default del rame, cioe' la configurazione gia' verificata.
#ifndef SENSORE_CON_MOSFET
#define SENSORE_CON_MOSFET 0
#endif

// Livello da mettere su SENS_CTRL per accendere il sensore.
#define SENS_CTRL_ACCESO (SENSORE_CON_MOSFET ? 0 : 1)

#define PIN_SDA   GPIO_NUM_22 // D4
#define PIN_SCL   GPIO_NUM_23 // D5
#define PIN_XSHUT GPIO_NUM_21 // D3

// BAT_SENSE: nodo del partitore 2x1 MOhm, con C1 da 100 nF.
#define PIN_BAT_SENSE GPIO_NUM_0 // D0

// GPIO0 e' ADC1_CH0 sull'ESP32-C6. Il canale va tenuto in coppia col pin:
// l'ADC non si programma per numero di GPIO.
#define ADC_BAT_UNIT    ADC_UNIT_1
#define ADC_BAT_CHANNEL ADC_CHANNEL_0

// --- Switch RF dell'antenna ------------------------------------------------
//
// Questi due GPIO non sono esposti sui 14 pin del connettore, quindi non
// compaiono sullo schema: esistono solo nel firmware.
//
// Nessuno dei due conserva lo stato attraverso il deep sleep: GPIO14 non e'
// un LP/RTC GPIO (sull'ESP32-C6 lo sono solo GPIO0..GPIO7), e GPIO3, che lo
// e', torna comunque al default se non si abilita l'hold. Vanno riscritti a
// OGNI risveglio, altrimenti il comando dello switch resta a mezz'aria.

#define PIN_RF_SWITCH_EN GPIO_NUM_3  // basso = controllo dello switch attivo
#define PIN_RF_ANT_SEL   GPIO_NUM_14 // basso = antenna ceramica integrata,
                                     // alto = connettore esterno

// Usiamo l'antenna integrata: il dispositivo sta nel contenitore, senza
// connettore U.FL montato.
#define RF_ANT_SEL_LEVEL 0
