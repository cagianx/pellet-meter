# Firmware del pellet-meter. ESP-IDF 5.x, target esp32c6.
#
# Il target non si scrive qui: sta in sdkconfig.defaults, cosi' un
# 'idf.py build' appena clonato il repo non ha bisogno di set-target.

cmake_minimum_required(VERSION 3.16)

include($ENV{IDF_PATH}/tools/cmake/project.cmake)

project(pellet-meter)
