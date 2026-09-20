// r11v69 w9 — ISOLATE ONE SHARE CELL SO uhdm-cmp's HEAD *IS* IT.  `lv` is
// gen-local with no namesake anywhere, so golden's `bindVariable` finds nothing,
// `tps` stays null and golden's Rhs is the SOURCE OBJECT.  Nothing else in the
// design can differ, so the head names that object's own fields.
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t LIT = '{n: 300};
endpackage

module dut #(parameter p::cfg_t CFG = p::LIT)
  (input logic a_i, output logic [31:0] o);
  if (1) begin : g
    logic [31:0] lv;
    assign lv = CFG.n;
    assign o = lv;
  end
endmodule
