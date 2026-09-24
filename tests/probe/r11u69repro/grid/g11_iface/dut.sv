// r11u69 g11 — AN INTERFACE's generate scope.  `emitGenScopes` has TWO
// callers: the module instance view and the interface instance view, so an
// interface gen-scope cont_assign is the second home the law reaches.
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t LIT = '{n: 6};
endpackage

interface ifc #(parameter p::cfg_t C = p::LIT) ();
  logic [31:0] i_top;
  logic [31:0] i_gen;
  assign i_top = C.n;              // CONTROL: interface module level
  if (1) begin : gi
    assign i_gen = C.n;
  end
endinterface

module dut (input logic a_i, output logic [31:0] o_t, o_g);
  ifc u_i ();
  assign o_t = u_i.i_top;
  assign o_g = u_i.i_gen;
endmodule
