import re
def show_chassis_hard_inventory(chassis_module):
    #find the first module:
    res = []
    regex_chassis_module = r'<chassis-(?:sub(?:-sub)?)?module>(.*?)</chassis-module>'
    # <name> is mandatory, make other captures optional
    regex_in_chassis_module = \
        r'<name>(.+?)</name>\n\s+<version>(.+?)</version>'\
        r'(?:\n\s+<part-number>(.+?)</part-number>)'\
        r'(?:\n\s+<serial-number>(.+?)</serial-number>)'\
        r'(?:\n\s+<description>(.+?)</description>)'\
        r'(?:\n\s+<clei-code>(.+?)</clei-code>)?'\
        r'(?:\n\s+<model-number>(.+?)</model-number>)'

    #find all (sub) modules:
    chassis_modules = re.findall(regex_chassis_module, chassis_module, re.DOTALL)
    print(chassis_modules)
    for chassis_module in chassis_modules:
        print("get-----\n", chassis_module, "\n-----\n")
        search_obj_in_module = re.search(regex_in_chassis_module, chassis_module, re.DOTALL)
        res += list(search_obj_in_module.groups()) + show_chassis_hard_inventory(chassis_module)
    return res

res = show_chassis_hard_inventory(chassis_module)


output2 = """
R1#show ip interface brief
Interface                  IP-Address      OK? Method Status                Protocol
FastEthernet0/0            15.0.15.1       YES manual up                    up
FastEthernet0/1            10.0.12.1       YES manual up                    up
FastEthernet0/2            10.0.13.1       YES manual up                    up
FastEthernet0/3            unassigned      YES unset  up                    up
Loopback0                  10.1.1.1        YES manual up                    up
Loopback100                100.0.0.1       YES manual up                    up
"""
