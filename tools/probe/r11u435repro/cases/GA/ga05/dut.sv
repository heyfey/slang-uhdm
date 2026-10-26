// § genCaAddParamIntCt435
module top #(parameter W = 'h2) ();
  logic [7:0] y;
  if (W <= 4) begin: g
    assign y = W + 1;
  end
endmodule
