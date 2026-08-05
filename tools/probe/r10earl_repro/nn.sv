// r10earl6 nn.sv — the array_typespec-vs-logic_typespec class (9 Earlgrey
// heads, the biggest UNTOUCHED class after pass 5).  Every one of the six
// declaration sites the census names is an UNPACKED-ARRAY declaration:
//     prim_arbiter_ppc.sv:40   input  [DW-1:0]   data_i    [N]
//     prim_arbiter_tree.sv:38  input  [DW-1:0]   data_i    [N]
//     prim_sram_arbiter.sv:24  input  [SramAw-1:0] req_addr [N]
//     rv_plic.sv:41            output [SRCW-1:0] irq_id_o  [NumTarget]
//     rv_plic_target.sv:31     input  [PrioWidth-1:0] prio [N_SOURCE]
//     ibex_alu.sv:406          logic  [ 5:0]     bitcnt_partial [32]   (a VAR)
// golden gives the declared type an array_typespec; we give it the packed
// logic_typespec alone (ports) or nothing (the var head reads
// "array_typespec vs <null>").
module nchild #(
  parameter int N  = 4,
  parameter int DW = 8
) (
  input                clk_i,
  // row A — an ANSI INPUT port with a packed range AND an unpacked dim
  input      [DW-1:0]  data_i [N],
  // row B — the same on an OUTPUT with `logic`
  output logic [DW-1:0] data_o [N],
  // row C — a SCALAR unpacked-array port (no packed range at all)
  input                 sel_i [N],
  // row D — a plain packed port (control)
  output logic [DW-1:0] plain_o
);
  // row E — an unpacked-array VAR (the ibex_alu shape)
  logic [5:0] bitcnt_partial [32];
  // row F — a scalar unpacked-array var (control)
  logic       flags [4];
  // row G — a plain packed var (control)
  logic [5:0] packed_only;

  always_comb begin
    bitcnt_partial[0] = 6'd0;
    flags[0] = 1'b0;
    packed_only = 6'd1;
  end
  assign data_o[0] = data_i[0];
  assign data_o[1] = {DW{sel_i[0]}};
  assign data_o[2] = '0;
  assign data_o[3] = '0;
  assign plain_o = data_i[0] ^ {2'b0, bitcnt_partial[0]};
endmodule

module nn (input logic clk_i, output logic [7:0] o);
  logic [7:0] d [4];
  logic [7:0] q [4];
  logic       s [4];
  always_comb begin
    d[0] = 8'h1; d[1] = 8'h2; d[2] = 8'h3; d[3] = 8'h4;
    s[0] = 1'b0; s[1] = 1'b0; s[2] = 1'b0; s[3] = 1'b0;
  end
  nchild #(.N(4), .DW(8)) u_n (
    .clk_i(clk_i), .data_i(d), .data_o(q), .sel_i(s), .plain_o(o)
  );
endmodule
