// § defGenLhsSelIdxThroughBase257 (a part select whose bounds hold genvar operations on a target)
module m #(parameter int N = 2)(input logic [1:0] x, output logic [2*N-1:0] y);
  for (genvar k = 0; k < N; k++) begin : gen_round
    if (1) begin : gen_a
      assign y[2*k+1:2*k] = x;
    end
  end
endmodule
module top; logic [1:0] x; logic [3:0] y; m u(.x(x), .y(y)); endmodule
