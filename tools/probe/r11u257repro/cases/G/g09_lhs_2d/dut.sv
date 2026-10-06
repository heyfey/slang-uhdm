// § defGenLhsSelIdxThroughBase257 (two selects on a target, each index a genvar operation)
module m #(parameter int N = 2)(input logic x, output logic [N:0][N:0] y);
  for (genvar k = 0; k < N; k++) begin : gen_round
    if (1) begin : gen_a
      assign y[k+1][k+1] = x;
    end
  end
endmodule
module top; logic x; logic [2:0][2:0] y; m u(.x(x), .y(y)); endmodule
