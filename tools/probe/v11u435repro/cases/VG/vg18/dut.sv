// § genCaAddParamIntCt435
module top #(parameter W = 4'd15) ();
  logic [7:0] y;
  if (1) begin: g
    assign y = W + 4'd1;
  end
endmodule
