// h8: R0, third cut — h7's module INSTANTIATED with parameter overrides, which
// is how `sram2tlul` appears in Earlgrey (u_tl_adapter_sram_* inside
// top_earlgrey).  h6 (plain) and h7 (struct-member LHS) both came back with
// golden and ours AGREEING that the size cast stays an unfolded
// `operation vpiOpType:67`; if this one still agrees, the 52-line head's
// discriminator is neither the cast shape, nor the struct-member LHS, nor the
// instantiation, and earl51 should look at the +define+SYNTHESIS / --single-unit
// compilation context instead.
package h8p;
  parameter int unsigned TL_AW  = 32;
  parameter int unsigned TL_SZW = 2;
  typedef struct packed {
    logic [1:0]  a_size;
    logic [31:0] a_address;
    logic        a_valid;
  } tl_h2d_t;
endpackage

module h8_sram2tlul #(
  parameter int SramAw = 12,
  parameter int SramDw = 32,
  parameter logic [h8p::TL_AW-1:0] TlBaseAddr = 'h0
) (
  input  logic [SramAw-1:0] mem_addr,
  input  logic              mem_req,
  output h8p::tl_h2d_t      tl_o
);
  localparam int unsigned SRAM_DWB = $clog2(SramDw/8);

  assign tl_o.a_valid   = mem_req;
  assign tl_o.a_size    = h8p::TL_SZW'(SRAM_DWB);
  assign tl_o.a_address = TlBaseAddr |
      {{(h8p::TL_AW-SramAw-SRAM_DWB){1'b0}}, mem_addr, {(SRAM_DWB){1'b0}}};
endmodule

module h8_earl50 (
  input  logic [11:0]  addr,
  input  logic         req,
  output h8p::tl_h2d_t tl
);
  h8_sram2tlul #(
    .SramAw(12),
    .SramDw(32),
    .TlBaseAddr(32'h1000_0000)
  ) u_sram2tlul (
    .mem_addr(addr),
    .mem_req(req),
    .tl_o(tl)
  );
endmodule
