module sub #(parameter int AW = 16)(input logic [AW-1:0] i);
  logic [AW-1:0] q;
endmodule
module recv #(parameter int AW = 5)(input logic [7:0] x);
  logic [7:0] w;
  sub #(8) s[3](.i(w));
endmodule
module top;
  logic [7:0] t;
  recv u (.x(t));
endmodule
