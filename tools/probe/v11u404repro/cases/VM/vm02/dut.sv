// § macroArgParamOrder404
`define LP(n, v) localparam n = v;
`define W(n) wire n;
module top #(parameter a0 = 1) ();
  `LP(z1, 3)
  localparam y1 = 2;
  `LP(x1, 1)
  `W(w2)
  wire w1;
endmodule
