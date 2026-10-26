// § genCaAddParamIntCt435
module top #(parameter W = 2) ();
  localparam P = 2 + 3;
  logic [31:0] y;
  if (W <= 4) begin: g
    assign y = P + 1;
  end
endmodule
