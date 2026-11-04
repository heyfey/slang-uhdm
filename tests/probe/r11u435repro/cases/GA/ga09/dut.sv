// § genCaAddParamIntCt435
module top #(parameter W = 2) ();
  localparam L = 2*3;
  logic [3:0] x;
  logic [31:0] y;
  if (W <= 4) begin: g
    assign y = $bits(x) + L;
  end
endmodule
