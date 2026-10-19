// § genLpUntypedDefNoTs410
module top #(parameter W = 4) (input logic [W-1:0] a, output logic [W-1:0] y);
  for (genvar i = 0; i < 2; i++) begin : g
    localparam R = 1.5;
    localparam N = $clog2(W);
  end
  assign y = a;
endmodule
