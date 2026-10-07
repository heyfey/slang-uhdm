// § bindChildDisplayScopedNames283
interface ifc; logic [3:0] q; endinterface
module tgt (input logic [3:0] d); ifc u_i (); assign u_i.q = d; endmodule
module mon (ifc p, input logic [3:0] d);
  for (genvar i = 0; i < 2; i++) begin : g
    logic [3:0] z;
    assign z = p.q;
  end
endmodule
module dut (input logic [3:0] d);
  tgt u_t1 (.d(d));
  tgt u_t2 (.d(d));
  bind tgt mon u_m (.p(u_i), .d(d));
endmodule
