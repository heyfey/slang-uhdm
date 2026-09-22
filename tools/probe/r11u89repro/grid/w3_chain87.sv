// r11u89 arm w3 — THE SIGNEDNESS PROPAGATES THROUGH THE SUBSTITUTED MINT.
// `DesignElaboration.cpp:2578-2587` reads the ELABORATED constant's own
// typespec (`cts`) and passes `cts ? cts : ts` to `valueRange` as the RHS —
// and when the initializer was a HOP whose store is signed, the mint at
// `CompileExpression.cpp:3032-3040` has already hung a BARE signed
// `int_typespec` on that constant.  So the outer hop's store is signed
// although its own declaration is UNSIGNED.  Chain depths x declared signs,
// MODULE-homed, 24-bit members, operand 0 a guaranteed bail.
package w3p;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
endpackage
module w3_chain87;
  // depth 1 — the landed law's own cells (declaration-signed)
  localparam int                 C1  = 16'd5;   // signed store, 16 wide
  localparam logic [15:0]        U1  = 16'd7;   // unsigned store
  // depth 2 — the DECLARATION is unsigned, the RHS's typespec is signed
  localparam logic [7:0]         C5  = C1;      // the brief's cell
  localparam logic [15:0]        C2  = C1;
  localparam int unsigned        C3  = C1;
  localparam bit [15:0]          C4  = C1;
  // depth 2 over an UNSIGNED inner — must stay bare
  localparam logic [7:0]         D2  = U1;
  localparam int unsigned        D3  = U1;
  // depth 3 — the flag must survive two hops
  localparam logic [7:0]         E3  = C5;
  localparam logic [3:0]         E4  = E3;
  // an unsigned declaration over a SIGNED-DECLARED inner of another kind
  localparam bit signed [15:0]   S1  = 16'd9;
  localparam logic [7:0]         S2  = S1;
  localparam logic [23:0]        S3  = S2;
  // the IMPLICIT declaration over a signed hop — `ts` may be absent, and
  // `valueRange` runs only `if (ts)`
  localparam                     I2  = C1;
  localparam signed              I3  = C1;
  localparam w3p::t A = '{bail: 8'hxA, a: C1, b: C5, c: C2, d: C3,
                          e: C4, f: U1, g: D2};
  localparam w3p::t B = '{bail: 8'hxA, a: D3, b: E3, c: E4, d: S1,
                          e: S2, f: S3, g: C5};
  localparam w3p::t C = '{bail: 8'hxA, a: I2, b: I3, c: C1, d: C5,
                          e: E3, f: S2, g: D2};
  w3_sink #(.R(A)) s1();
  w3_sink #(.R(B)) s2();
  w3_sink #(.R(C)) s3();
endmodule
module w3_sink #(parameter w3p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule
