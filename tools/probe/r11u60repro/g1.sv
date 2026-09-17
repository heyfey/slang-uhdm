// g1 — THE MIRROR ARM, packed.  One package; five identical packed-struct
// localparams differing ONLY in which package-scope trigger (if any) reduces
// them; two holders that wildcard-import all five.  g1q touches NOTHING, so
// only the package side can decide its DEF-view import copies.
package p1;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } pb_t;
  localparam pb_t PSEL = '{a: 8'd1,  b: 8'd2};   // package-scope member select
  localparam pb_t PSCP = '{a: 8'd3,  b: 8'd4};   // p1::PSCP whole read, from a module
  localparam pb_t PNON = '{a: 8'd5,  b: 8'd6};   // never read
  localparam pb_t PMOD = '{a: 8'd7,  b: 8'd8};   // member select in a MODULE only
  localparam pb_t PFUN = '{a: 8'd9,  b: 8'd10};  // select in a package FUNCTION body
  typedef logic [PSEL.a-1:0] selv_t;             // <- the package-scope select
  function automatic int unsigned pf1();
    return PFUN.b;                               // <- the package-function select
  endfunction
endpackage

module g1q import p1::*; (input logic clk);      // QUIET holder: touches nothing
  selv_t sv;
  assign sv = '0;
endmodule

module g1r (output logic [15:0] o1, o2);         // the readers
  import p1::*;
  assign o1 = p1::PSCP;
  assign o2 = {PMOD.a, PMOD.b};
endmodule

module g1top(input logic clk);
  logic [15:0] a1, a2;
  g1q u_q (.clk(clk));
  g1r u_r (.o1(a1), .o2(a2));
endmodule
