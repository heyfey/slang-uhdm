// § defGenLhsSelIdxThroughBase257 (an indexed part select target whose base is an operation, plus a down part select)
module m #(parameter int N = 2)(input logic [15:0] x, output logic [15:0] y);
  logic [15:0] v;
  for (genvar k = 0; k < N; k++) begin : gen_round
    assign v[k*4+:4] = x[k*4+:4];
    assign v[k*4+11-:4] = x[k*4+11-:4];
  end
  assign y = v;
endmodule
module top; logic [15:0] x, y; m u(.x(x), .y(y)); endmodule
