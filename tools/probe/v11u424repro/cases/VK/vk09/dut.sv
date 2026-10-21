// § boundSizedLitKept424
module sub #(parameter logic [4'd7:0] P = 8'h3) (input [3'd7:0] a, output logic [P:0] b);
  logic [2'd3:0] q;
endmodule
module top; logic [7:0] a; logic [3:0] b; sub #(.P(3)) s(a, b); endmodule
