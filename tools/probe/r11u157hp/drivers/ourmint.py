# r11u157: gdb Python for OUR -g1 exporter: every Serializer::Make<T> (T in $OM_TYPES) with its UhdmId (object+24) and
# the first frames that sit in src/ or include/ (file:line function). Also every ref_obj::VpiFullName setter (id, value,
# src frame) and every BaseClass::VpiColumnNo setter on a ref_obj is NOT traced (setLoc is inlined). Output $OM_OUT.
import gdb, json, os
OM_TYPES = os.environ.get('OM_TYPES', 'ref_obj,hier_path').split(',')
OM_OUT = os.environ['OM_OUT']
OM_recs = []; OM_full = []
def om_src_frames(f, n=6):
    out = []; k = 0
    while f is not None and len(out) < n and k < 40:
        try:
            sal = f.find_sal(); fn = sal.symtab.filename if sal.symtab else ''
        except Exception: fn = ''
        if '/src/' in fn or '/include/' in fn:
            nm = (f.name() or '??').split('(')[0].split('::')[-1]
            out.append(f'{os.path.basename(fn)}:{sal.line} {nm}')
        f = f.older(); k += 1
    return out
class OM_FB(gdb.FinishBreakpoint):
    def __init__(self, frame, t, bt):
        super().__init__(frame, internal=True); self.t = t; self.bt = bt
    def stop(self):
        p = int(gdb.parse_and_eval('$rax'))
        i = int(gdb.parse_and_eval(f'*(unsigned int*)({p}+24)'))
        OM_recs.append([self.t, i, self.bt]); return False
    def out_of_scope(self): pass
class OM_BP(gdb.Breakpoint):
    def __init__(self, t):
        super().__init__('UHDM::Serializer::Make' + t[0].upper() + t[1:], internal=True); self.t = t
    def stop(self):
        OM_FB(gdb.newest_frame(), self.t, om_src_frames(gdb.newest_frame()))
        return False
class OM_FN(gdb.Breakpoint):
    def __init__(self, t):
        super().__init__(f'UHDM::{t}::VpiFullName(std::basic_string_view<char, std::char_traits<char> >)', internal=True); self.t = t
    def stop(self):
        this = int(gdb.parse_and_eval('$rdi')); n = int(gdb.parse_and_eval('$rsi')); d = int(gdb.parse_and_eval('$rdx'))
        i = int(gdb.parse_and_eval(f'*(unsigned int*)({this}+24)'))
        s = bytes(gdb.selected_inferior().read_memory(d, n)).decode(errors='replace') if 0 < n < 400 else ''
        OM_full.append([self.t, i, s, om_src_frames(gdb.newest_frame(), 3)]); return False
for t in OM_TYPES: OM_BP(t)
OM_FN('ref_obj')
def OM_done(ev): json.dump({'mint': OM_recs, 'full': OM_full}, open(OM_OUT, 'w'))
gdb.events.exited.connect(OM_done)
