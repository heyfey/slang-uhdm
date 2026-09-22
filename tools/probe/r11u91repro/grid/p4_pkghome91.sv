// r11u91 arm p4 — the package-fed read in the OTHER two homes
// `red87HopHomeIsInstance87` accepts (a generate block, an interface body),
// the BINARY package hop whose VALUE field is wrong on both binaries, an
// IMPLICIT declaration that carries only a signing keyword, and the two
// negative controls a package inner must not break.
package p4p;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
  localparam int                QI  = 16'd5;
  localparam logic signed [7:0] QBS = 8'b1010;   // SIGNED, but a BIN leaf
  localparam logic signed [7:0] QHS = 8'h1A;     // SIGNED, a HEX leaf
  localparam signed             QSI = 16'd5;     // implicit + a signing word
  localparam int                QOV = 16'd9;
endpackage
module p4_pkghome91;
  localparam logic [7:0] U1 = p4p::QBS;
  localparam logic [7:0] U2 = p4p::QHS;
  localparam logic [7:0] U3 = p4p::QSI;
  localparam logic [7:0] U4 = p4p::QI;
  localparam p4p::t A = '{bail: 8'hxA, a: U1, b: U2, c: U3, d: U4,
                          e: U4, f: U2, g: U1};
  p4_sink #(.R(A)) s1();
  if (1) begin : gb
    localparam logic [7:0] G1 = p4p::QI;
    localparam logic [7:0] G2 = p4p::QHS;
    localparam p4p::t B = '{bail: 8'hxA, a: G1, b: G2, c: G1, d: G2,
                            e: G1, f: G2, g: G1};
    p4_sink #(.R(B)) s2();
  end
  p4_ifc u_if();
  p4_mid #(.O(32'd9)) m1();
endmodule
interface p4_ifc ();
  localparam logic [7:0] I1 = p4p::QI;
  localparam logic [7:0] I2 = p4p::QHS;
  localparam p4p::t C = '{bail: 8'hxA, a: I1, b: I2, c: I1, d: I2,
                          e: I1, f: I2, g: I1};
endinterface
module p4_mid #(parameter int O = 16'd5) ();
  // the OVERRIDE gate: an overridden hop never reaches the store road at all
  localparam logic [7:0] M1 = p4p::QOV;
  localparam p4p::t D = '{bail: 8'hxA, a: O, b: M1, c: O, d: M1,
                          e: O, f: M1, g: O};
  p4_sink #(.R(D)) s4();
endmodule
module p4_sink #(parameter p4p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule
