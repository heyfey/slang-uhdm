package mask_pkg;
  localparam logic [63:0] MASK = 64'hDEADBEEF_12345678;
  localparam int unsigned W = 16;
  parameter int P = 5;
endpackage
module top (input logic s, input logic [3:0] k, output logic [15:0] o);
  assign o = s ? mask_pkg::MASK[mask_pkg::W-1:0] : '0;
endmodule
