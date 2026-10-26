// § genCaConstRhsWhole433
module top #(parameter W = 2) (output [31:0] y, z);
  logic [4:0] x;
  assign z = W + 1;
  if (W <= 4) begin: g
    assign y = W + 1;
  end
endmodule
