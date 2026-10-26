// § genCaConstRhsWhole433
module top #(parameter W = 2) (output [31:0] y, z, output [63:0] w);
  if (W > 1) begin: g
    assign y = 7;
    assign z = 'd9;
    assign w = W + 1;
  end
endmodule
