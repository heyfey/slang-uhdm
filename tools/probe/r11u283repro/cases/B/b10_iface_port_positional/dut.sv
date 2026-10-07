// § bindChildDisplayScopedNames283
interface ifc; logic [3:0] sig; modport mp (input sig); endinterface
module leaf (input logic a, output logic y); assign y = a; endmodule
module chk (ifc.mp p, output logic o); assign o = p.sig[0]; endmodule
module top (output logic o);
  ifc inst ();
  logic a;
  leaf l1 (.a(a), .y(o));
endmodule
bind leaf chk b_c (top.inst, );
