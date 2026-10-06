// § defGenLhsSelIdxThroughBase257 (a bare genvar index on a target inside a generate if)
module m #(parameter int N = 2)(input logic [7:0] x, output logic [7:0] y [N]);
  for (genvar k = 0; k < N; k++) begin : gen_round
    if (1) begin : gen_a
      assign y[k] = x;
    end
  end
endmodule
module top; logic [7:0] x; logic [7:0] y [2]; m u(.x(x), .y(y)); endmodule
