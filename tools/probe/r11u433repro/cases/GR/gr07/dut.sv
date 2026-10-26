// § genCaConstRhsWhole433
module top #(parameter W = 2) (output [31:0] y, z);
  logic [4:0] x;
  assign z = x;
  if (W <= 4) begin: g
    assign y = x;
  end
endmodule
