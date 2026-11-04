// § defGenLhsSelIdxThroughBase257 (a genvar index operation on a packed target inside a generate if)
module m #(parameter int N = 2)(input logic x, output logic [N:0] y);
  assign y[0] = x;
  for (genvar k = 0; k < N; k++) begin : gen_round
    if (1) begin : gen_a
      assign y[k+1] = y[k];
    end
  end
endmodule
module top; logic x; logic [2:0] y; m u(.x(x), .y(y)); endmodule
