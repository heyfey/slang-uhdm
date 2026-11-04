// § genCaConstRhsWhole433
module top #(parameter W = 2) ();
  if (W <= 4) begin: g
    logic [3:0] q;
    if (W > 1) begin: h
      assign q = W + 1;
    end
  end
endmodule
