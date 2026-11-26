# Il componente 'main' in ESP-IDF dipende implicitamente da tutti gli altri,
# quindi non serve elencare REQUIRES per driver, esp_sleep e compagnia.

idf_component_register(
    SRCS "main.c"
    INCLUDE_DIRS "."
)
