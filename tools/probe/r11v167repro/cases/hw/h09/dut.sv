// § hpDotWsTrimmed167
module sub;
  logic [7:0] v;
endmodule
module top (input logic [7:0] a, output logic [7:0] y);
  sub u();
  assign u . v = a;
  assign y = u . v;
endmodule
