// § bindChildDisplayScopedNames283
module tgt (input logic [3:0] d, output logic [3:0] o); assign o = d; endmodule
module mon (input logic [3:0] d);
  logic [3:0] y [2];
  for (genvar i = 0; i < 2; i++) begin : g
    assign y[i] = d;
  end
endmodule
module dut (input logic [3:0] d, output logic [3:0] o);
  tgt u_t (.d(d), .o(o));
  bind tgt mon m1 (.d(d)), m2 (.d(d));
endmodule
