package mask_pkg;
  localparam logic [63:0] MASK = 64'hDEADBEEF_12345678;
  parameter logic [31:0] PMASK = 32'hA5A5_0F0F;
  localparam int unsigned W = 16;
endpackage
module top (output logic [15:0] o);
  assign o = mask_pkg::MASK[mask_pkg::W-1:0];
endmodule
