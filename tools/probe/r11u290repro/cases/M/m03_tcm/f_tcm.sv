// § elabOvMisevalRestampFile290
`include "hdr.svh"
module tcm #(parameter TCM_SIZE = 32'h00010000)(
  input logic clk,
  input logic [31:0] imem_addr,
  input logic [31:0] dmem_addr,
  output logic [31:0] q);
dpm #(
  .SIZE ( TCM_SIZE )
) i_dp (
  .clk   ( clk ),
  .addra ( imem_addr[$clog2(TCM_SIZE)-1:2] ),
  .addrb ( dmem_addr[$clog2(TCM_SIZE)-1:2] ),
  .qa    ( q ));
endmodule
