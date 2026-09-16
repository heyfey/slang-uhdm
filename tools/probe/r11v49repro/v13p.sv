// v11u49 arm v13p — LAW A x WIDTH x SYMBOLIC DIM combined, UNPACKED.
package p;
  localparam int W = 40;
  typedef struct packed { logic [W-1:0] a; logic [W-1:0] b; logic [W-1:0] c; } wide_t;  // 120 bits, symbolic
  localparam wide_t WSEL = '{a:40'd1, b:40'd2, c:40'd3};   // member-selected in-package
  localparam wide_t WNON = '{a:40'd4, b:40'd5, c:40'd6};   // never read
  localparam int USE = WSEL.b;
endpackage
module v13p import p::*; (output logic [31:0] o);
  assign o = USE + WNON.a;
endmodule
