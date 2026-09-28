// § ndaSysCallNetTs212 — r11u217 n01: net declarations with whole-initializer system calls in a PARAMETERIZED child instantiated twice (v11u212 e05 / g11: the instance's folded range): `wire [W-1:0] a = $unsigned(x);`, `wire signed [W-1:0] b = $signed(x);`
module ch #(parameter int W = 4) (input logic [W-1:0] x, output logic [W-1:0] o, output logic [W-1:0] p);
  wire [W-1:0] a = $unsigned(x);
  wire signed [W-1:0] b = $signed(x);
  assign o = a;
  assign p = b;
endmodule
module dut(input logic [7:0] x, output logic [3:0] o, output logic [3:0] p, output logic [7:0] q, output logic [7:0] r);
  ch u (.x(x[3:0]), .o(o), .p(p));
  ch #(.W(8)) v (.x(x), .o(q), .p(r));
endmodule
