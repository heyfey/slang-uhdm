// § genLpUntypedDefNoTs410
module sub #(parameter W = 4) (input logic [W-1:0] a, output logic [W-1:0] y);
  for (genvar i = 0; i < 2; i++) begin : g
    parameter P = 2;
    localparam Q = 'h3;
    localparam R = 1'b1;
  end
  assign y = a;
endmodule
module top (input logic [3:0] a, output logic [3:0] y);
  sub #(4) u(.a(a), .y(y));
endmodule
