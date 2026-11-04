// § genCaConstRhsWhole433
module top #(parameter W = 4) (output [31:0] y, z, output [7:0] p);
  if (W > 1) begin: g
    logic [6:0] q;
    assign y = $size(q);
    assign z = $clog2(W) + $bits(q);
    assign p[3:0] = $size(q);
  end
endmodule
