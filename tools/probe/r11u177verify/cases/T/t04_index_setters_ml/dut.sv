// § ppOutputLine166 § ppOutputCol166 § tagPatSortSrcOrder177v
`define ADD2(x, y) \
  ((x) + \
   (y))
module top #(parameter int W = 8) (input logic a, output logic [7:0] b);
  localparam logic [7:0] A [2] = '{1: W - 1, 0: `ADD2(W, 1)};
  assign b = a ? A[0] : A[1];
endmodule
