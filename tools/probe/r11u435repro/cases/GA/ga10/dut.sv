// § genCaAddParamIntCt435
module top #(parameter W = 2) ();
  localparam L = W << 1;
  logic [31:0] y;
  if (W <= 4) begin: g
    assign y = L + 1;
  end
endmodule
