// § genCaFoldTsChainNamed169
module dut (input logic [31:0] a [2], input logic [3:0] b [8], output logic [31:0] o [2]);
  parameter int P = 6;
  localparam int Q = P + 1;
  for (genvar c = 0; c < 2; c++) begin : g
    assign o[c] = {31'b0, a[c][c ? P : 0]};
  end
endmodule
