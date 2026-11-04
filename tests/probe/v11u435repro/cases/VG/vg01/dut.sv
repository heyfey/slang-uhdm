// § genCaAddParamIntCt435
module top #(parameter W = 8) ();
  logic [7:0] y;
  if (1) begin: g
    assign y = W/2 + 1;
  end
endmodule
