// § hpDotWsTrimmed167 — three components through two instance levels, blanks before one dot and after the other
module leaf (input logic [3:0] i);
  logic [3:0] r;
  assign r = i;
endmodule
module mid (input logic [3:0] i);
  leaf l (.i(i));
endmodule
module top (input logic [3:0] a, output logic [3:0] y);
  mid m (.i(a));
  assign y = m .l. r;
endmodule
