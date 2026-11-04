package mask_pkg;
  localparam logic [63:0] MASK = 64'hDEADBEEF_12345678;
  parameter logic [31:0] PMASK = 32'hA5A5_0F0F;
  localparam int unsigned W = 16;
  logic [31:0] v;
endpackage
module top (input logic clk, input logic s, output logic [7:0] o);
  always_ff @(posedge clk) o <= s ? mask_pkg::MASK[15:8] : 8'h0;
endmodule
