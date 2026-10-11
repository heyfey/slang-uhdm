// § genCaSelBoundNestedOwner282
module top #(parameter int P = 2) (input logic [7:0] b, input logic c, output logic [1:0] z);
  logic [1:0] v;
  assign z = v;
  for (genvar g = 0; g < 1; g++) begin : gb
    assign v = c ? b[P +: 2] : 2'd1;
  end
endmodule
