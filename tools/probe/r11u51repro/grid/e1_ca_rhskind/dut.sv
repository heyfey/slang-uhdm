// ROAD E: UhdmWriter::writeCont_assign's `simplified == false` reduceExpr runs
// on the ELABORATED cont_assign only.  Vary the Rhs KIND over one holder.
package p;
  typedef struct packed { int unsigned n; logic [63:0] base; } cfg_t;
  localparam cfg_t LIT = '{n: 3, base: 64'h1000};
endpackage
module dut #(parameter p::cfg_t CFG = p::LIT, parameter int PW = 7)
           (input logic [63:0] a_i,
            output logic [31:0] o_h, output logic [31:0] o_r,
            output logic [31:0] o_p, output logic [63:0] o_b,
            output logic [31:0] o_v);
  assign o_h = CFG.n;          // Rhs = hier_path over a struct parameter
  assign o_r = PW;             // Rhs = ref_obj to a scalar parameter
  assign o_p = PW + 1;         // Rhs = operation over a parameter
  assign o_b = CFG.base;       // Rhs = hier_path, wider member
  assign o_v = a_i[31:0];      // Rhs = non-constant (control: must stay)
endmodule
