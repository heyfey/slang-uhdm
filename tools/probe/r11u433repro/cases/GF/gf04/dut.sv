// § genCaConstRhsWhole433
module top #(parameter W = 2) (output [31:0] y, output [7:0] p);
  if (W > 1) begin: g
    logic [5:0] z;
    assign y = $bits(z);
    assign p[3:0] = $bits(z);
  end
endmodule
