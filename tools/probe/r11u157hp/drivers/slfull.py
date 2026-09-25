# r11u157: gdb Python for the pinned Surelog: every UHDM::ref_obj::VpiFullName(std::string_view) SETTER call with the
# object's UhdmId (this+24), the string (rsi=len? SysV: this=rdi, string_view passed as (rsi=size, rdx=data)) and the
# caller chain. Output JSON: $SLFULL_OUT. Filter ids with $SLFULL_IDS (comma list, empty = all).
import gdb, json, os
F_OUT = os.environ['SLFULL_OUT']; F_IDS = set(int(x) for x in os.environ.get('SLFULL_IDS', '').split(',') if x)
F_recs = []
class F_BP(gdb.Breakpoint):
    def __init__(self, spec, t):
        super().__init__(spec, internal=True); self.t = t
    def stop(self):
        this = int(gdb.parse_and_eval('$rdi')); n = int(gdb.parse_and_eval('$rsi')); d = int(gdb.parse_and_eval('$rdx'))
        i = int(gdb.parse_and_eval(f'*(unsigned int*)({this}+24)'))
        if F_IDS and i not in F_IDS: return False
        s = ''
        if 0 < n < 400:
            s = bytes(gdb.selected_inferior().read_memory(d, n)).decode(errors='replace')
        f = gdb.newest_frame().older(); bt = []; k = 0
        while f is not None and k < 7:
            bt.append((f.name() or '??').split('(')[0].split('::')[-1]); f = f.older(); k += 1
        F_recs.append([self.t, i, s, bt])
        return False
for t in os.environ.get('SLFULL_TYPES', 'ref_obj').split(','):
    F_BP(f'UHDM::{t}::VpiFullName(std::basic_string_view<char, std::char_traits<char> >)', t)
def F_done(ev): json.dump(F_recs, open(F_OUT, 'w'))
gdb.events.exited.connect(F_done)
