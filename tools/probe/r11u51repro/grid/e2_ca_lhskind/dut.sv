// ROAD E: the same constant Rhs against five LHS kinds.
package p;
  typedef struct packed { int unsigned n; logic [63:0] base; } cfg_t;
  localparam cfg_t LIT = '{n: 3, base: 64'h1000};
endpackage
module dut #(parameter p::cfg_t CFG = p::LIT)
           (output logic [31:0] o_full, output logic [31:0] o_bit,
            output logic [31:0] o_part, output logic [31:0] o_arr [2],
            output logic signed [31:0] o_sgn);
  assign o_full    = CFG.n;    // plain named net
  assign o_bit[0]  = CFG.n[0]; // bit-select LHS
  assign o_part[3:0] = CFG.n[3:0];  // part-select LHS
  assign o_arr[0]  = CFG.n;    // unpacked-array element LHS
  assign o_sgn     = CFG.n;    // signed net LHS
endmodule
