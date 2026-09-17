// v3 - ANSI PORTS carrying an unpacked-array typedef, every direction, plus an
// ANSI port with an explicit net keyword.  OPS caution (b): ports are a
// different kind, and the def-view net loop mints a logic_net for them.
package pk3;
  typedef logic [1:0] pa_t [4];
  typedef logic [1:0] pv_t;
endpackage
module sub import pk3::*; (
    input  pa_t pin,          // ANSI input, unpacked-array typedef (imported)
    output pa_t pout,
    input  pv_t pvin [2],     // ANSI input, packed typedef + declarator dim
    output pk3::pa_t qout,    // ANSI output, SCOPED unpacked-array typedef
    output logic [1:0] o
);
  pa_t sbody;
  assign pout = pin;
  assign qout = pin;
  assign sbody = pin;
  assign o = pin[0] | pvin[0] | sbody[0];
endmodule
module dut import pk3::*; (output logic [1:0] o);
  pa_t a, b, q;
  pv_t vv [2];
  logic [1:0] so;
  sub u (.pin(a), .pout(b), .pvin(vv), .qout(q), .o(so));
  assign a[0] = 2'b0;
  assign o = b[0] | q[0] | so;
endmodule
