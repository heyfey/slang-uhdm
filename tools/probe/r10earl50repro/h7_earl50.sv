// h7: R0 again, with the ONE thing h6 left out — the cont-assign's LHS is a
// MEMBER of a packed struct, exactly as in sram2tlul.sv:42
// (`assign tl_o.a_size = top_pkg::TL_SZW'(SRAM_DWB);`).  h6 measured the plain
// shape and golden AGREED with us there (DUMP_MATCH, 6/6 cells), so the
// discriminator for the 52-line head is somewhere in this direction.
package h7p;
  parameter int unsigned TL_AW  = 32;
  parameter int unsigned TL_SZW = 2;
  typedef struct packed {
    logic [1:0]  a_size;
    logic [31:0] a_address;
    logic        a_valid;
  } tl_h2d_t;
endpackage

module h7_earl50 #(
  parameter int SramAw = 12,
  parameter int SramDw = 32
) (
  input  logic [SramAw-1:0] mem_addr,
  input  logic              mem_req,
  output h7p::tl_h2d_t      tl_o
);
  localparam int unsigned SRAM_DWB = $clog2(SramDw/8);

  assign tl_o.a_valid   = mem_req;
  assign tl_o.a_size    = h7p::TL_SZW'(SRAM_DWB);
  assign tl_o.a_address = 32'h0 |
      {{(h7p::TL_AW-SramAw-SRAM_DWB){1'b0}}, mem_addr, {(SRAM_DWB){1'b0}}};
endmodule
