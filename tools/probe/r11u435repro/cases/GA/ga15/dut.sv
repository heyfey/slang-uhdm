// § genCaAddParamIntCt435
module top #(parameter W = 2) ();
  logic [31:0] y;
  if (W <= 4) begin: g
    localparam G = 2*2;
    assign y = G + 1;
  end
endmodule
