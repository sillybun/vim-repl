import numpy as np
import dill
from typing import Dict

class myclass:
    def __init__(self):
        self.x = 1
        self.y = 1

x = myclass()

y: int = 1

z: Dict[str, int] = {"ZYT": 1993}

z["zyt"] = 1993

dill.dump_session("UUUU.log")


