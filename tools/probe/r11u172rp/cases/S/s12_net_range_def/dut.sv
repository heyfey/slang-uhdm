module sub #(parameter int W = 8) (input logic [W-1:0] a, output logic [W-1:0] y);
  logic [$unsigned(W)-1:0] t;
  assign t = a;
  assign y = t;
endmodule
module top (input logic [3:0] a, output logic [3:0] y);
  sub #(.W(4)) u (.a(a), .y(y));
endmodule
