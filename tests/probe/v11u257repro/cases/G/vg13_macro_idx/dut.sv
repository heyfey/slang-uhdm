// § defGenLhsSelIdxThroughBase257 (the operation index comes from a macro)
`define NX(a) a+1
module m #(parameter int N = 2)(input logic [7:0] x, output logic [7:0] y);
  logic [7:0] st [N+1]; assign st[0] = x;
  for (genvar k = 0; k < N; k++) begin : gen_round assign st[`NX(k)] = st[k]; end
  assign y = st[N];
endmodule
module top; logic [7:0] x, y; m u(.x(x), .y(y)); endmodule
