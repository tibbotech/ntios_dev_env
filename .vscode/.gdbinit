handle SIGALRM ignore
set pagination off

python
import gdb
import re


class PropertyPrinter:
    def __init__(self, val):
        self.val = val

    def find_address(self, ptr):
        obj_ptr_str = str(ptr)
        obj_addr = 0
        match = re.search(r'\b0x[\da-f]+\b', obj_ptr_str)
        if match is not None:
            obj_addr = match.group(0)
        else:
            raise ValueError('Unable to extract address from function pointer string')
        return obj_addr


    def to_string(self):
        try:
            parent_ptr = self.val['parent']
            getter_ptr = self.val['getterFuncPtr']

            parent_addr = self.find_address(parent_ptr)
            getter_addr = self.find_address(getter_ptr)

            parent_type = parent_ptr.type.target()
    
            if parent_ptr.type.code == gdb.TYPE_CODE_PTR:
                parent_type = str(parent_ptr.type.target().unqualified())
            else:
                parent_type = str(parent_ptr.type.unqualified())

            parent_ptr_type = gdb.lookup_type(parent_type).pointer()
            getter_type = str(getter_ptr.type)

            # Extract the type name of the template instantiation from the getter type
            template_name = getter_type.split('<', maxsplit=1)[0].strip()
            template_name = template_name.rsplit(' ', maxsplit=1)[-1]

            template_args =  getter_type.strip('>::getter_t').split('<')[1].split(', ')
            return_type = gdb.lookup_type(template_args[0]).unqualified()
            parent_arg_type = gdb.lookup_type(template_args[1]).pointer()

            cmd = f'(({return_type} (*)({parent_arg_type})){getter_addr})(({parent_ptr_type}) {parent_addr})'
            value = gdb.parse_and_eval(cmd)  # Call the getter function
            return str(value)
        except Exception as e:
            return ""

class PropertyPermissions:
    Read = 1 << 0
    Write = 1 << 1

def lookup_type(val):
    if val.type.code == gdb.TYPE_CODE_REF:
        val = val.referenced_value()
    type_name = val.type.strip_typedefs().tag
    if 'Property<' in type_name:
        return PropertyPrinter(val)
    return None

gdb.pretty_printers.append(lookup_type)

end


    

python
import sys
sys.path.insert(0, '/usr/share/gcc/python')
from libstdcxx.v6.printers import register_libstdcxx_printers
register_libstdcxx_printers (None)
end



define lookup
python
val = gdb.Value(int(gdb.parse_and_eval("$arg0")))
gdb.execute("ptype " + str(val.type))
end
end