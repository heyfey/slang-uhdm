package mask_pkg;
  localparam logic [63:0] MASK = 64'hDEADBEEF_12345678;
  parameter logic [31:0] PMASK = 32'hA5A5_0F0F;
  localparam int unsigned W = 16;
endpackage
module top (output logic [7:0] o);
  if (1) begin : g
    assign o = mask_pkg::MASK[7:0];
  end
endmodule
