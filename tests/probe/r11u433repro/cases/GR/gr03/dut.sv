// § genCaConstRhsWhole433
module top #(parameter W = 2) (output [31:0] y, z);
  logic [4:0] x;
  assign z = 5;
  if (W <= 4) begin: g
    assign y = 5;
  end
endmodule
