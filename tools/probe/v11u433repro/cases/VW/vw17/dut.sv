// § genCaConstRhsWhole433
module top #(parameter W = 2) ();
  wire [7:0] y;
  for (genvar i = 0; i < 2; i++) begin: g
    if (i == 0) begin: h
      assign y = W + 1;
    end
  end
endmodule
