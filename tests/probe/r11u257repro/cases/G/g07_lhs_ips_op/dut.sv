// § defGenLhsSelIdxThroughBase257 (an indexed part select with a genvar operation base on a target)
module m #(parameter int N = 2)(input logic [1:0] x, output logic [2*N-1:0] y);
  for (genvar k = 0; k < N; k++) begin : gen_round
    if (1) begin : gen_a
      assign y[2*k+:2] = x;
    end
  end
endmodule
module top; logic [1:0] x; logic [3:0] y; m u(.x(x), .y(y)); endmodule
