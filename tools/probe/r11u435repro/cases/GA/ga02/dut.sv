// § genCaAddParamIntCt435
module top #(parameter W = 2) ();
  localparam L = 2*3;
  localparam M = 10 - 3;
  logic [31:0] y, z;
  if (W <= 4) begin: g
    assign y = L + 1;
    assign z = M + 1;
  end
endmodule
