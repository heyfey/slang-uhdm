// r11v89 break arm x4 — LAW A's CHAIN EDGES.  The recursion reads ONLY the
// inner hop's DECLARATION (home, explicit type, signedness) and never its
// initializer's SHAPE.  An inner whose own store was built on a road that
// does not call `valueRange` — an OPERATION, a system call, a real — would be
// a false positive.  Depth 9..11 tests the `depth89 < 8` cap.
package x4p;
  localparam int PIN = 16'd5;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
endpackage
module x4_chned89;
  // an inner whose initializer is an OPERATION / a system call / a hop into
  // a package — none of which the recursion looks at
  localparam int         CO  = 16'd5 + 16'd1;
  localparam logic [7:0] CO2 = CO;
  localparam int         CF  = $clog2(8);
  localparam logic [7:0] CF2 = CF;
  localparam int         CP  = x4p::PIN;
  localparam logic [7:0] CP2 = CP;
  // the DEPTH CAP: eleven hops over a signed root
  localparam int         H0  = 16'd5;
  localparam logic [7:0] H1 = H0;   localparam logic [7:0] H2 = H1;
  localparam logic [7:0] H3 = H2;   localparam logic [7:0] H4 = H3;
  localparam logic [7:0] H5 = H4;   localparam logic [7:0] H6 = H5;
  localparam logic [7:0] H7 = H6;   localparam logic [7:0] H8 = H7;
  localparam logic [7:0] H9 = H8;   localparam logic [7:0] H10 = H9;
  localparam x4p::t A = '{bail: 8'hxA, a: CO, b: CO2, c: CF, d: CF2,
                          e: CP, f: CP2, g: CO2};
  localparam x4p::t B = '{bail: 8'hxA, a: H7, b: H8, c: H9, d: H10,
                          e: H1, f: H4, g: H10};
  x4_sink #(.R(A)) s1();
  x4_sink #(.R(B)) s2();
endmodule
module x4_sink #(parameter x4p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule
