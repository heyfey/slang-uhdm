// § genLpUntypedDefNoTs410
module top;
  parameter W = 8;
  for (genvar i = 0; i < 2; i++) begin : g
    localparam S = W / 4;
    localparam int U = W;
    parameter V = 2;
  end
endmodule
