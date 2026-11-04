// § genCaConstRhsWhole433
module top #(parameter W = 2) (output [31:0] y, z);
  logic [4:0] x;
  assign z = W ? 3 : 4;
  if (W <= 4) begin: g
    assign y = W ? 3 : 4;
  end
endmodule
