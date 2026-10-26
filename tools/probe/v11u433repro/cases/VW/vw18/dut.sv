// § genCaConstRhsWhole433
module top #(parameter W = 2) ();
  wire [7:0] y;
  if (W <= 4) begin: g
    assign y = (W > 1) ? 8'd3 : 8'd4;
  end
endmodule
