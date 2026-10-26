// § genCaAddParamIntCt435
module top #(parameter W = 4'd2) ();
  logic [7:0] y [2];
  for (genvar i = 0; i < 2; i++) begin: g
    assign y[i] = W + i;
  end
endmodule
