// v11u69 v7 — THE INTERFACE FENCE, pushed.  (a) a generate block in an
// INTERFACE whose Lhs is an interface-body variable (golden SHARES: bindVariable
// has no interface_inst case), (b) the SAME but with the name ALSO declared in
// the instantiating module — bindVariable recurses past the interface into the
// module and FINDS it, so golden should CLONE there while the patch's
// `iface=1` gate declines unconditionally, and (c) a module gen scope in the
// same design as a control.
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t LIT = '{n: 31};
endpackage

interface ifc #(parameter p::cfg_t C = p::LIT) ();
  logic [31:0] i_gen;     // interface-only name
  logic [31:0] shared;    // name ALSO declared in the instantiating module
  if (1) begin : gi
    assign i_gen  = C.n;
    assign shared = C.n;
  end
endinterface

module dut #(parameter p::cfg_t CFG = p::LIT)
  (input logic a_i, output logic [31:0] o_i, o_s, o_m);
  logic [15:0] shared;    // the MODULE-side namesake, DIFFERENT width
  ifc u_if ();
  assign o_i = u_if.i_gen;
  assign o_s = u_if.shared;
  if (1) begin : gd
    assign o_m = CFG.n;   // CONTROL: a module gen scope, law fires
  end
  assign shared = 16'd0;
endmodule
