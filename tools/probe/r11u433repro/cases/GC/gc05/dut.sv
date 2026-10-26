// § genCaConstRhsWhole433
package pk;
  parameter P = 4;
endpackage
module top #(parameter W = 2) (output [31:0] y, z);
  import pk::*;
  if (W > 1) begin: g
    assign y = pk::P + 1;
    assign z = P * W;
  end
endmodule
