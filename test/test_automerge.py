a= "1123\
    4567"

a = """123
134
678"""

print(a)

b = 1 + 2\
        +3\
        +4
print(b)

def f(a, b):
    return a + b

b = 1 + 2\
    +3\
    +4\
    + f(1,
    2) +\
    5

print(b)

a = "abc\
        def"

print(a)

output1 = """
R1#show ip interface brief
Interface                  IP-Address      OK? Method Status                Protocol
FastEthernet0/0            15.0.15.1       YES manual up                    up
FastEthernet0/1            10.0.12.1       YES manual up                    up
FastEthernet0/2            10.0.13.1       YES manual up                    up
FastEthernet0/3            unassigned      YES unset  up                    up
Loopback0                  10.1.1.1        YES manual up                    up
Loopback100                100.0.0.1       YES manual up                    up
"""
