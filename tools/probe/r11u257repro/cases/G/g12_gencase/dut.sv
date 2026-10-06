// § defGenLhsSelIdxThroughBase257 (a target index operation inside a generate case)
module m #(parameter int N = 2, parameter int S = 1)(input logic x, output logic [N:0] y);
  for (genvar k = 0; k < N; k++) begin : gen_round
    case (S)
      1: begin : c1 assign y[k+1] = x; end
      default: begin : cd assign y[k+1] = ~x; end
    endcase
  end
endmodule
module top; logic x; logic [2:0] y; m u(.x(x), .y(y)); endmodule
