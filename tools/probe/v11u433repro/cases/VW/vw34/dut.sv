// § genCaConstRhsWhole433
module top #(parameter W = 2) ();
  wire [7:0] y;
  if (W <= 4) begin: g
    if (W > 0) begin: h
      assign y = W - 1;
    end
  end
endmodule
