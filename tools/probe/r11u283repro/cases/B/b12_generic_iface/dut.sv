// § bindChildDisplayScopedNames283
interface ifc; logic [3:0] sig; endinterface
module leaf (input logic a, output logic y); assign y = a; endmodule
module chk (interface p, output logic o); assign o = p.sig[0]; endmodule
module top (output logic o);
  ifc inst ();
  logic a;
  if (1) begin : g
    leaf l2 (.a(a), .y(o));
  end
endmodule
bind leaf chk b_c (.p(top.inst), .o());
