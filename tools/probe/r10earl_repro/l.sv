package top_p;
  localparam int TL_AW = 32;
  localparam int TL_DW = 32;
endpackage

package tlul_p;
  typedef struct packed {
    logic [top_p::TL_AW-1:0] a_address;
    logic [top_p::TL_DW-1:0] a_data;
  } tl_h2d_t;
endpackage

module sram2 #(
  parameter int                          SramAw     = 12,
  parameter logic [top_p::TL_AW-1:0]     TlBaseAddr = 'h0
) (
  input clk_i,
  output tlul_p::tl_h2d_t tl_o
);
endmodule
