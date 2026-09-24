// r10earl9 witness A — the "$clog2 of an EXPRESSION as a declaration range
// bound" family.  Census heads:
//   dm_sba.sv:63:17      operation      vs ref_obj 'BusWidth/8'
//   prim_packer.sv:42:17 operation      vs ref_obj 'InW+1'
//   hmac.sv:309:17       operation      vs ref_obj '32+1'
//   pinmux.sv:157:22     operation      vs ref_obj 'NMioPads+2'
// Every one is a module-scope (or gen-scope) VARIABLE declaration whose packed
// range bound is `$clog2(<binary expression>)`; the head is the ARGUMENT of
// the sys_func_call, which we emit as ONE ref_obj literally NAMED with the
// argument's source text.
module ua #(
  parameter int BusWidth = 32,
  parameter int InW      = 10
) (
  input  logic        clk_i,
  output logic        o
);
  // row A — division, the dm_sba shape
  logic [$clog2(BusWidth/8)-1:0] a_idx;
  // row B — addition of a param and a literal, the prim_packer shape
  logic [$clog2(InW+1)-1:0]      b_idx;
  // row C — addition of two literals, the hmac shape
  logic [$clog2(32+1)-1:0]       c_idx;
  // row D — $clog2 of a PLAIN identifier (control: already agrees?)
  logic [$clog2(BusWidth)-1:0]   d_idx;
  // row E — $clog2 of a plain literal (control)
  logic [$clog2(64)-1:0]         e_idx;
  // row F — 2** around the call, the pinmux shape
  logic [2**$clog2(InW+2)-1:0]   f_idx;
  // row G — a NON-$clog2 expression bound (control for the parse path)
  logic [BusWidth/8-1:0]         g_idx;

  assign o = ^{a_idx, b_idx, c_idx, d_idx, e_idx, f_idx, g_idx} ^ clk_i;
endmodule
