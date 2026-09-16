// r11v55 VERIFIER arm — W1'S CHAIN, PUSHED.  structParamPattern55 hops
// NamedValue -> Parameter -> getInitializer() up to 8 times.  Every hop is a
// bet that the symbol it lands on carries THIS instance's value.  Cut:
//   u_thru  — leaf's CFG is overridden with the PARENT's parameter, which is
//             itself overridden at the parent's instantiation (two hops, two
//             instance boundaries);
//   u_2hop  — leaf's CFG defaults to a module localparam that is itself
//             `= p::LIT2` (a pure in-scope chain);
//   u_deflt — the plain default (control).
// If any hop reads a DECLARED default where the instance carries an OVERRIDE,
// the folded constant is WRONG, and wrong silently.
package p;
  typedef struct packed { int unsigned n; logic [63:0] base; } cfg_t;
  localparam cfg_t LIT  = '{n: 3,  base: 64'h1000};
  localparam cfg_t LIT2 = '{n: 21, base: 64'h2000};
  localparam cfg_t LIT3 = '{n: 55, base: 64'h3000};
endpackage
module leaf #(parameter p::cfg_t CFG = p::LIT)
            (output logic [31:0] o_n, output logic [63:0] o_b);
  assign o_n = CFG.n;
  assign o_b = CFG.base;
endmodule
module mid #(parameter p::cfg_t PCFG = p::LIT)
           (output logic [31:0] o_n, output logic [63:0] o_b);
  leaf #(.CFG(PCFG)) u_thru (.o_n(o_n), .o_b(o_b));
endmodule
module dut (output logic [31:0] t_n, output logic [63:0] t_b,
            output logic [31:0] h_n, output logic [63:0] h_b,
            output logic [31:0] d_n, output logic [63:0] d_b);
  localparam p::cfg_t LOC = p::LIT2;
  mid  #(.PCFG(p::LIT3)) u_mid (.o_n(t_n), .o_b(t_b));   // override through a parent param
  leaf #(.CFG(LOC))      u_2hop(.o_n(h_n), .o_b(h_b));   // chain through a module localparam
  leaf                   u_dflt(.o_n(d_n), .o_b(d_b));   // plain default (control)
endmodule
