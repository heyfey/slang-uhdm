package mask_pkg;
  localparam logic [63:0] MASK = 64'hDEADBEEF_12345678;
  parameter logic [31:0] PMASK = 32'hA5A5_0F0F;
  localparam int unsigned W = 16;
  logic [31:0] v;
endpackage
module top (input logic [3:0] s, output logic o);
  always_comb begin
    o = 1'b0;
    if (s == mask_pkg::MASK[3:0]) o = 1'b1;
  end
endmodule
