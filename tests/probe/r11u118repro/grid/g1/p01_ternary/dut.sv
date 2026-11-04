package mask_pkg;
  localparam logic [63:0] MASK = 64'hDEADBEEF_12345678;
  parameter logic [31:0] PMASK = 32'hA5A5_0F0F;
  localparam int unsigned W = 16;
endpackage
module top #(parameter int XLEN = 32) (input logic sel_i, output logic [XLEN-1:0] o_o);
  assign o_o = sel_i ? mask_pkg::MASK[XLEN-1:0] : '0;
endmodule
