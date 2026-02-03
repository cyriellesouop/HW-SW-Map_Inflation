# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "")
  file(REMOVE_RECURSE
  "/home/audrey/Documents/convolution/Map_inflation/hardware_impl/test_IP/sim_mb_customIP_multAdd/vitis_ws_testIP/platform/microblaze_0/standalone_microblaze_0/bsp/include/sleep.h"
  "/home/audrey/Documents/convolution/Map_inflation/hardware_impl/test_IP/sim_mb_customIP_multAdd/vitis_ws_testIP/platform/microblaze_0/standalone_microblaze_0/bsp/include/xiltimer.h"
  "/home/audrey/Documents/convolution/Map_inflation/hardware_impl/test_IP/sim_mb_customIP_multAdd/vitis_ws_testIP/platform/microblaze_0/standalone_microblaze_0/bsp/include/xtimer_config.h"
  "/home/audrey/Documents/convolution/Map_inflation/hardware_impl/test_IP/sim_mb_customIP_multAdd/vitis_ws_testIP/platform/microblaze_0/standalone_microblaze_0/bsp/lib/libxiltimer.a"
  )
endif()
