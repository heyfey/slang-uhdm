// § genCaConstRhsWhole433
module top #(parameter W = 2, parameter D = 1) (output [31:0] y, z);
  if (W <= 4) begin: g
    assign #D y = W + 1;
  end
  assign z = W;
endmodule
