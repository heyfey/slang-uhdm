// § defGenLhsSelIdxThroughBase257 (a descending indexed part select with an operation base on a target)
module m #(parameter int N = 2)(input logic [1:0] x, output logic [2*N-1:0] y);
  for (genvar k = 0; k < N; k++) begin : gen_round
    assign y[2*k+1-:2] = x;
  end
endmodule
module top; logic [1:0] x; logic [3:0] y; m u(.x(x), .y(y)); endmodule
