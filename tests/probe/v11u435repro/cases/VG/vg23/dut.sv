// § genCaAddParamIntCt435
module top #(parameter W = 4'D2) ();
  logic [7:0] y;
  if (1) begin: g
    assign y = W + 1;
  end
endmodule
