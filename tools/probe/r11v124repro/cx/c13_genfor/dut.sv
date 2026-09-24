// § castTsFile124
module top(input logic [7:0] a, output logic [3:0] o [2]); for (genvar i = 0; i < 2; i++) begin : g assign o[i] = 4'(a + i); end endmodule
