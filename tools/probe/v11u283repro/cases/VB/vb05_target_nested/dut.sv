// § bindChildDisplayScopedNames283
module leaf (input logic [3:0] d); endmodule
module tgt (input logic [3:0] d); leaf u_l (.d(d)); endmodule
module mon (input logic [3:0] d);
  logic [3:0] y [2];
  for (genvar i = 0; i < 2; i++) begin : g
    assign y[i] = d;
  end
endmodule
module mid (input logic [3:0] d); tgt u_t (.d(d)); endmodule
module dut (input logic [3:0] d);
  mid u_mid (.d(d));
  bind leaf mon u_m (.d(d));
endmodule
