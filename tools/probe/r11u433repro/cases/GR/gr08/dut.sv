// § genCaConstRhsWhole433
module top #(parameter W = 2) (output [31:0] y, z);
  logic [4:0] x;
  assign z = x + 1;
  if (W <= 4) begin: g
    assign y = x + 1;
  end
endmodule
