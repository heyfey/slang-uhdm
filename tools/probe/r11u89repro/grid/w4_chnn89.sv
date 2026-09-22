// r11u89 arm w4 — THE CHAIN'S NEGATIVE CONTROLS.  The recursive read must NOT
// fire where the inner hop's own store is not signed: a PACKAGE-homed inner
// (`CompileHelper.cpp:3754-3772` never calls `setSigned`), an OVERRIDDEN inner
// (`DesignElaboration.cpp:2510` skips the whole loop), an inner whose atom kind
// `valueRange`'s switch does not name (`byte`/`shortint`/`integer`/`longint`),
// and an inner read through a CAST rather than a bare name.
package w4p;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
  localparam int PIN = 16'd5;          // package-homed, store NOT signed
endpackage
module w4_chnn89;
  localparam int          PIN2 = 16'd6;
  localparam logic [7:0]  N1 = w4p::PIN;     // over a package inner
  localparam logic [7:0]  N2 = PIN2;         // over a module-homed inner
  localparam shortint     A1 = 16'd5;        // an ABSTAINED atom kind
  localparam logic [7:0]  N3 = A1;
  localparam int          B1 = 16'd5;        // signed inner
  localparam logic [7:0]  N4 = signed'(B1);  // read through a CAST
  localparam logic [7:0]  N5 = B1 + 0;       // read through an OPERATION
  localparam logic [7:0]  N6 = $unsigned(B1);
  localparam w4p::t A = '{bail: 8'hxA, a: N1, b: N2, c: A1, d: N3,
                          e: N4, f: N5, g: N6};
  w4_mid #(.O(32'd9)) m1();
  localparam w4p::t B = '{bail: 8'hxA, a: N1, b: N3, c: N4, d: N5,
                          e: N6, f: B1, g: PIN2};
  w4_sink #(.R(A)) s1();
  w4_sink #(.R(B)) s2();
endmodule
module w4_mid #(parameter int O = 16'd5) ();
  // the inner is OVERRIDDEN: its store is built on the override road and
  // `valueRange` never runs, so the outer hop must stay bare.
  localparam logic [7:0] M1 = O;
  localparam w4p::t D = '{bail: 8'hxA, a: O, b: M1, c: M1, d: O,
                          e: M1, f: O, g: M1};
  w4_sink #(.R(D)) s3();
endmodule
module w4_sink #(parameter w4p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule
