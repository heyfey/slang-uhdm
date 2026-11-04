// § genCaConstRhsWhole433
module top #(parameter W = 2) ();
  wire [7:0] y, z, v;
  if (W <= 4) begin: g
    assign y = W + 4'd3;
    assign z = 8'hF0 & W;
    assign v = W + 2'b11;
  end
endmodule
