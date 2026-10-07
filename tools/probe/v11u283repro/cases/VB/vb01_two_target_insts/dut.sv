// § bindChildDisplayScopedNames283
module tgt (input logic [3:0] d, output logic [3:0] o); assign o = d; endmodule
module mon (input logic [3:0] d);
  logic [3:0] y [2];
  for (genvar i = 0; i < 2; i++) begin : g
    assign y[i] = d;
  end
endmodule
module dut (input logic [3:0] d, output logic [3:0] o1, o2);
  tgt u_t1 (.d(d), .o(o1));
  tgt u_t2 (.d(d), .o(o2));
  bind tgt mon u_m (.d(d));
endmodule
