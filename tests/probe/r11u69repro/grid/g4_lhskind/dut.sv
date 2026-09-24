// r11u69 g4 — Lhs KINDS inside ONE generate block, Rhs held at exactly `CFG.n`
// (the ve1 cut, re-homed).  Seven Lhs: plain 32-bit, narrow 8-bit, wide 64-bit,
// signed, bit-select, part-select, unpacked-array element.
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t LIT = '{n: 300};
endpackage

module dut #(parameter p::cfg_t CFG = p::LIT)
  (input  logic        a_i,
   output logic [31:0] o_plain,
   output logic [7:0]  o_narrow,
   output logic [63:0] o_wide,
   output logic signed [31:0] o_sgn,
   output logic [31:0] o_bit,
   output logic [31:0] o_part,
   output logic [31:0] o_arr [0:1]);

  if (1) begin : gblk
    assign o_plain    = CFG.n;
    assign o_narrow   = CFG.n;
    assign o_wide     = CFG.n;
    assign o_sgn      = CFG.n;
    assign o_bit[0]   = CFG.n;
    assign o_part[3:0]= CFG.n;
    assign o_arr[0]   = CFG.n;
  end
endmodule
