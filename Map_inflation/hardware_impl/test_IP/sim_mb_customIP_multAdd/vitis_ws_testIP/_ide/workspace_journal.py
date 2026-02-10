# 2026-02-09T20:22:31.083243
import vitis

client = vitis.create_client()
client.set_workspace(path="vitis_ws_testIP")

vitis.dispose()

