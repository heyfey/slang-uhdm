// § bindChildDisplayScopedNames283
interface ifc; logic [3:0] sig; modport mp (input sig); endinterface
module leaf (input logic a, output logic y); assign y = a; endmodule
module chk (ifc.mp p, output logic o);
  if (1) begin : g
    assign o = p.sig[0];
  end
endmodule
module top (output logic [1:0] o);
  ifc inst ();
  logic a;
  leaf l1 (.a(a), .y(o[0]));
  leaf l2 (.a(a), .y(o[1]));
endmodule
bind leaf chk b_c (.p(top.inst), .o());
