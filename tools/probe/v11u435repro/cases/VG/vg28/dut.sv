// § genCaAddParamIntCt435
module top #(parameter W = 4'd2) ();
  logic [7:0] y, z;
  if (1) begin: g
    if (1) begin: h
      assign y = W + 1;
    end
  end
  assign z = W + 1;
endmodule
