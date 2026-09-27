# mktrace.py (gdb -batch -x mktrace.py --args <binary> ...; TRACE_OUT=<file>): one line per UHDM::Serializer::MakeLogic_typespec call,
# its four caller frames; used ONLY on Earlgrey_0_1 (not fenced) for the byte coin, evidence/earlgrey_coin.txt.
import gdb
out = open(gdb.parameter("logging file") if False else __import__('os').environ['TRACE_OUT'], 'w')
class BP(gdb.Breakpoint):
    def stop(self):
        f = gdb.newest_frame().older()
        names = []
        for i in range(4):
            if f is None: break
            names.append(f.name() or hex(f.pc()))
            f = f.older()
        out.write(' < '.join(names) + '\n')
        return False
BP('UHDM::Serializer::MakeLogic_typespec')
gdb.execute('run')
out.close()
gdb.execute('quit')
