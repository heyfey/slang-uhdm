// § genCaAddParamIntCt435
module top #(parameter W = 4'd2, parameter V = W) ();
  logic [7:0] y;
  if (1) begin: g
    assign y = V + 1;
  end
endmodule
