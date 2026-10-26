// § genCaAddParamIntCt435
module top #(parameter W = 2) ();
  localparam L = -3;
  logic [31:0] y;
  if (W <= 4) begin: g
    assign y = L + 5;
  end
endmodule
