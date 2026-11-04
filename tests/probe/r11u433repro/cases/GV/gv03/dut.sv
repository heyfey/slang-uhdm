// § genCaConstRhsWhole433
module top #(parameter W = 3) (output [31:0] y, output [7:0] p);
  if (W > 1) begin: g
    assign y = $clog2(W) + 1;
    assign p[3:0] = $clog2(W) + 1;
    assign p[7:4] = $bits(y) - W;
  end
endmodule
