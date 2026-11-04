// § genCaAddParamIntCt435
module top #(parameter W = 4'd2) ();
  logic [7:0] y;
  if (1) begin: g
    assign y = W + 32'd4000000000;
  end
endmodule
