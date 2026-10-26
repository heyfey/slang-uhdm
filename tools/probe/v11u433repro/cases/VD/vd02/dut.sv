// § genCaConstRhsWhole433
module top #(parameter W = 2, parameter D = 1) (output [31:0] y);
  logic [4:0] x;
  if (W <= 4) begin: g
    assign #D y = $bits(x);
  end
endmodule
