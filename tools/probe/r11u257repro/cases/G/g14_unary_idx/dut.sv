// § defGenLhsSelIdxThroughBase257 (a parenthesized and a unary index on targets)
module m #(parameter int N = 2)(input logic x, output logic [N:0] y, output logic [N:0] z);
  for (genvar k = 0; k < N; k++) begin : gen_round
    assign y[(k)] = x;
    assign z[N-k] = x;
  end
endmodule
module top; logic x; logic [2:0] y, z; m u(.x(x), .y(y), .z(z)); endmodule
