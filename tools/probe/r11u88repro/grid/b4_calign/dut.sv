// v11u83 b4 -- LAW B BREAK: the index alignment.  The interface body mixes a
// plain cont_assign, a NET-DECLARATION assignment, an explicit
// generate-region cont_assign and a trailing plain one -- four cells whose
// def order emitContAssigns builds by rotating the gen-region entry to the
// end.  If the rebuilt caOrder mis-aligns, a cell folds ANOTHER cell's value.
package pk;
  typedef struct packed { logic [7:0] n; logic [7:0] m; } s_t;
endpackage

interface ifc #(parameter pk::s_t C = '{n: 8'd6, m: 8'd9}) ();
  logic [31:0] a;
  logic [31:0] b;
  logic [31:0] c;
  assign a = C.n;
  wire  [31:0] d = C.m;
  generate
    assign b = C.m;
  endgenerate
  assign c = C.n;
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.a ^ u_if.b ^ u_if.c ^ u_if.d;
endmodule
