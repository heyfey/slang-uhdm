// r11v89 break arm x5 — THE CENSUS HOLE AND THE HOME GATE'S REAL SUBJECT.
// LAW B's home gate reads the IMMEDIATE hop (`red86HopName86`), while the
// width comes from `red81StoreCt81`'s walk down the whole chain.  A
// MODULE-homed hop whose value arrives from a PACKAGE-homed wide literal
// therefore passes the gate although the store that produced the digits was
// built on the package road.  census89's WID89 classifier walks the chain and
// asks `not inpkg` at the LITERAL, so it does not sight this shape at all.
package x5p;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
  localparam logic [95:0] PW96 = 96'd12;
  localparam logic [95:0] PO96 = 96'o17;
endpackage
module x5_pkgchn89;
  localparam logic [95:0] X1 = x5p::PW96;   // module-homed hop, package inner
  localparam logic [95:0] X2 = x5p::PO96;
  localparam logic [95:0] X3 = 96'd12;      // the direct module hop, control
  localparam x5p::t A = '{bail: 8'hxA, a: X1, b: X2, c: X3, d: X1,
                          e: X2, f: X3, g: X1};
  x5_sink #(.R(A)) s1();
endmodule
module x5_sink #(parameter x5p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule
