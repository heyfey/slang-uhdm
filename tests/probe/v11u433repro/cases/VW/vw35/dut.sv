// § genCaConstRhsWhole433
module top #(parameter W = 2) ();
  wire [7:0] y;
  if (W <= 4) begin: g
    assign y = (W + 1) << 2;
  end
  else begin: e
    assign y = W;
  end
endmodule
