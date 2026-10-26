// § genCaConstRhsWhole433
module top #(parameter W = 2) (output [31:0] y, output [7:0] z [2]);
  if (W > 1) begin: g
    assign y = (W > 1) && (W < 4);
    assign z[0] = W + 1;
    assign z[1] = W / 2;
  end
endmodule
