from hdl_if.decorators import api, imp, exp
from hdl_if import ctypes as ct

@api
class sample:
    @imp
    async def delay(self, cycle: ct.c_int64):
        pass

    @imp
    def get_sim_time(self) -> ct.c_int64:
        pass
    
    @exp
    async def hello_world_from_python(self):
        print(f"{self.get_sim_time()}: Hello World from Python")
        await self.delay(2)
        print(f"{self.get_sim_time()}: after self.delayed() 1st time")
        await self.delay(3)
        print(f"{self.get_sim_time()}: after self.delayed() 2nd time")
