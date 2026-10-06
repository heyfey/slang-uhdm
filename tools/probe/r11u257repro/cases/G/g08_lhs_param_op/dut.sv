// § defGenLhsSelIdxThroughBase257 (a parameter in the target's index operation)
module m #(parameter int N = 2, parameter int O = 1)(input logic x, output logic [N+O:0] y);
  for (genvar k = 0; k < N; k++) begin : gen_round
    if (1) begin : gen_a
      assign y[k+O] = x;
    end
  end
endmodule
module top; logic x; logic [3:0] y; m u(.x(x), .y(y)); endmodule
