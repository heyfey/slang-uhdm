// ROAD E: WHICH OBJECT does the producer substitute?  The pattern element's
// own constant (stamped with the LITERAL's source location) or a fresh one?
// Three reads of the same field, and one read of a field written by an
// EXPRESSION rather than a literal.
package p;
  typedef struct packed { int unsigned n; logic [63:0] base; } cfg_t;
  localparam int unsigned K = 3;
  localparam cfg_t LIT  = '{n: 3,     base: 64'h1000};
  localparam cfg_t LIT2 = '{n: K + 1, base: 64'h2000};
endpackage
module dut #(parameter p::cfg_t CFG = p::LIT, parameter p::cfg_t CFG2 = p::LIT2)
           (output logic [31:0] o1, output logic [31:0] o2, output logic [31:0] o3);
  assign o1 = CFG.n;
  assign o2 = CFG.n;
  assign o3 = CFG2.n;
endmodule
