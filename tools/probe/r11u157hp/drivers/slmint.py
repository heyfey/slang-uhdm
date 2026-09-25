# r11u157: gdb Python for the PINNED Surelog binary (no DWARF; symbols only): record, for every object minted by
# Serializer::Make<T> for the types in $SLMINT_TYPES, its UhdmId (read at object+24: RTTI vptr, serializer_, clientData_,
# uhdmId_ -- UHDM c7562484 templates/BaseClass.h) and the minting backtrace (function names). Output JSON: $SLMINT_OUT.
import gdb, json, os
M_TYPES = os.environ.get('SLMINT_TYPES', 'ref_obj,hier_path,bit_select').split(',')
M_OUT = os.environ['SLMINT_OUT']
M_recs = []
class M_FB(gdb.FinishBreakpoint):
    def __init__(self, frame, t, bt):
        super().__init__(frame, internal=True); self.t = t; self.bt = bt
    def stop(self):
        try:
            p = int(self.return_value) if self.return_value is not None else int(gdb.parse_and_eval('$rax'))
        except Exception:
            p = int(gdb.parse_and_eval('$rax'))
        i = int(gdb.parse_and_eval(f'*(unsigned int*)({p}+24)'))
        M_recs.append([self.t, i, self.bt])
        return False
    def out_of_scope(self): pass
class M_BP(gdb.Breakpoint):
    def __init__(self, t):
        super().__init__('UHDM::Serializer::Make' + t[0].upper() + t[1:], internal=True); self.t = t
    def stop(self):
        f = gdb.newest_frame(); bt = []; k = 0
        while f is not None and k < 10:
            n = f.name() or '??'
            bt.append(n); f = f.older(); k += 1
        M_FB(gdb.newest_frame(), self.t, bt)
        return False
for t in M_TYPES: M_BP(t)
def M_done(ev): json.dump(M_recs, open(M_OUT, 'w'))
gdb.events.exited.connect(M_done)
