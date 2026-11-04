// § genCaCastRhsRefUnnamed198
module l3 #(parameter int N = 2) (input logic [3:0] b, output logic [2:0] y [2]);
  if (N > 1) begin : g
    assign y[0] = 3'(b);
    assign y[1] = 3'(~b);
  end
endmodule
module l2 (input logic [3:0] b, output logic [2:0] y [2]);
  l3 u3 (.b(b), .y(y));
endmodule
module top (input logic [3:0] b, output logic [2:0] y [2]);
  l2 u2 (.b(b), .y(y));
endmodule
