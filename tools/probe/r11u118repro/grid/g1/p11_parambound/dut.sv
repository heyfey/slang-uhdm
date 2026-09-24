package mask_pkg;
  localparam logic [63:0] MASK = 64'hDEADBEEF_12345678;
  parameter logic [31:0] PMASK = 32'hA5A5_0F0F;
  localparam int unsigned W = 16;
endpackage
module top #(parameter int XLEN = 8) (output logic [XLEN-1:0] o);
  assign o = mask_pkg::MASK[XLEN-1:0];
endmodule
