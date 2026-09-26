// § genCaFoldTsChainNamed169
module dut (input logic [31:0] b [2], output logic [31:0] o [2]);
  parameter int P = 6;
  for (genvar c = 0; c < 2; c++) begin : g
    if (1) begin : a
      wire [3:0] a;
      assign a = b[c][3:0];
      assign o[c] = {31'b0, a[P % 4]};
    end
  end
endmodule
