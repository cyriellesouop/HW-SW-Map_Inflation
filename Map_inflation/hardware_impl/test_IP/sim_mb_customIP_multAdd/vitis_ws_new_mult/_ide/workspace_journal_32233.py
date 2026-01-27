# 2026-01-16T15:14:41.780685
import vitis

client = vitis.create_client()
client.set_workspace(path="vitis_ws_new_mult")

platform = client.get_component(name="platform")
status = platform.build()

comp = client.get_component(name="hello_world")
comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

vitis.dispose()

