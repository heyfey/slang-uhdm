// § wildcardConnRefSpan130
module sub #(parameter W=2)(input logic [W-1:0] a, output logic [W-1:0] y);
  assign y = ~a;
endmodule
module top(input logic [3:0] a, output logic [3:0] y);
  sub #(.W(4)) u1 (.*);
endmodule
