// § genCaAddParamIntCt435
module top #(parameter W = 4'd2) ();
  logic [7:0] y;
  logic [3:0] n;
  if (1) begin: g
    assign y = W + n;
  end
endmodule
