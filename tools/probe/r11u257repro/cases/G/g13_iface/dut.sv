// § defGenLhsSelIdxThroughBase257 (a target index operation in an interface's generate loop)
interface ifc #(parameter int N = 2)(input logic x); logic [N:0] y;
  for (genvar k = 0; k < N; k++) begin : gen_round
    assign y[k+1] = x;
  end
endinterface
module top; logic x; ifc u(.x(x)); endmodule
