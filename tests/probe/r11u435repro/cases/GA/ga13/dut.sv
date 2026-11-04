// § genCaAddParamIntCt435
module top #(parameter W = 2) ();
  localparam L = 4'd3;
  logic [7:0] y;
  if (W <= 4) begin: g
    assign y = 1 + L;
  end
endmodule
