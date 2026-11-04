// § genCaAddParamIntCt435
module top #(parameter W = 2) ();
  localparam N = 3000000000;
  logic [31:0] y;
  if (W <= 4) begin: g
    assign y = N + 1;
  end
endmodule
