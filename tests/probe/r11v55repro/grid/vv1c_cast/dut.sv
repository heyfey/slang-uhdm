// r11v55 — a CAST wrapping the pattern, plus the named-pattern control.
package p;
  typedef struct packed { int unsigned n; logic [15:0] h; } cfg_t;
  localparam cfg_t CAST  = cfg_t'('{n: 9,  h: 16'h00AB});
  localparam cfg_t NAMED = '{n: 12, h: 16'h00CD};
endpackage
module dut #(parameter p::cfg_t P3 = p::CAST, parameter p::cfg_t P4 = p::NAMED)
           (output logic [31:0] o_c, output logic [31:0] o_n);
  assign o_c = P3.n;   // cast-wrapped pattern
  assign o_n = P4.n;   // control
endmodule
