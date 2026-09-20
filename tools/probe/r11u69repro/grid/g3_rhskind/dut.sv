// r11u69 g3 — Rhs KINDS inside ONE generate block (the ve2 cut, re-homed).
// One Lhs kind (plain 32-bit net), one home (a named gen-if), eight Rhs.
package p;
  typedef struct packed { int unsigned n; int unsigned m; } inner_t;
  typedef struct packed { inner_t sub; int unsigned k; } outer_t;
  typedef struct packed { int unsigned n; logic [15:0] h; } cfg_t;
  localparam cfg_t  LIT  = '{n: 3, h: 16'hBEEF};
  localparam outer_t OLIT = '{sub: '{n: 11, m: 12}, k: 13};
  localparam int unsigned AP [0:1] = '{21, 22};
endpackage

module dut #(parameter p::cfg_t CFG = p::LIT, parameter p::outer_t OC = p::OLIT)
  (input  logic [31:0] a_i,
   output logic [31:0] o_field,
   output logic [31:0] o_nest,
   output logic [31:0] o_oper,
   output logic [31:0] o_concat,
   output logic [31:0] o_arrp,
   output logic [15:0] o_hex,
   output logic [31:0] o_nc1,
   output logic [31:0] o_nc2);

  if (1) begin : gblk
    assign o_field  = CFG.n;              // 1-level field read
    assign o_nest   = OC.sub.n;           // 2-level field read (W2)
    assign o_oper   = CFG.n + 1;          // operation containing a field read
    assign o_concat = {16'h0, CFG.n[15:0]};  // concat containing a field read
    assign o_arrp   = p::AP[0];           // unpacked-ARRAY parameter element
    assign o_hex    = CFG.h;              // a based HEX member
    assign o_nc1    = CFG.n + a_i;        // CONTROL: not constant
    assign o_nc2    = a_i;                // CONTROL: not constant
  end
endmodule
