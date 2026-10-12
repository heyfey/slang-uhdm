// § genNdaSelRhsSharesNet303
module top #(parameter int P = 42405) (input logic [63:0] arr, input logic [7:0] b, c, input logic s, output logic o);
  function automatic logic f(logic [7:0] x); return x[0]; endfunction
  for (genvar i = 0; i < 2; ++i) begin : g
    wire w = f(b);
  end
  assign o = arr[0];
endmodule
