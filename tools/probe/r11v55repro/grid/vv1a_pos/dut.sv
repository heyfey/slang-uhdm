// r11v55 — POSITIONAL (simple) assignment pattern as the struct parameter's value.
package p;
  typedef struct packed { int unsigned n; logic [15:0] h; } cfg_t;
  localparam cfg_t POS = '{3, 16'hBEEF};
endpackage
module dut #(parameter p::cfg_t P1 = p::POS)
           (output logic [31:0] o_n, output logic [31:0] o_h);
  assign o_n = P1.n;
  assign o_h = P1.h;
endmodule
