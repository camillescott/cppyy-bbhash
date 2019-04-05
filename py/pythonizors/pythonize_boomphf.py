import re

from cppyy import gbl

def match_template(short_name, full_name):
    '''
    Check that a given full name the template instantiation for the template named by short_name.
    '''
    expr = re.compile(r'{0}<\S*>'.format(short_name))
    return expr.match(full_name)


def is_template_inst(short_name, full_name):
    match = match_template(short_name.strip(), full_name.strip())
    if not match:
        return False
    else:
        return match.string == full_name.strip()


def pythonize_boomphf_mphf_query(klass, name):
    if is_template_inst('mphf', name):
        def query(self, key):
            val = self.lookup(key)
            if val != gbl.kMaxULong64:
                return val
            else:
                return None
        klass.query = query
