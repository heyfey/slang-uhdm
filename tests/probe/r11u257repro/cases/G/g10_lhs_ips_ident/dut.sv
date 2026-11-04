// § defGenLhsSelIdxThroughBase257 (an indexed part select with a bare genvar base on a target)
module m #(parameter int N = 2)(input logic x, output logic [N-1:0] y);
  for (genvar k = 0; k < N; k++) begin : gen_round
    if (1) begin : gen_a
      assign y[k+:1] = x;
    end
  end
endmodule
module top; logic x; logic [1:0] y; m u(.x(x), .y(y)); endmodule
