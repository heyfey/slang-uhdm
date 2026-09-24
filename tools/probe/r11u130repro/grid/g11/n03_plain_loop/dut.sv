// § genvarIntTsRootFile130
module top(input logic [1:0] a, output logic [1:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i] = a[i];
  end
endmodule
