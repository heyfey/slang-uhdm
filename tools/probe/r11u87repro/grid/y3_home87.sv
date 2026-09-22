// r11u87 arm y3 — THE HOP'S HOME DECIDES BOTH FACES.  A MODULE-homed hop's
// store is built in `DesignElaboration.cpp:2578-2585` (fromVpiValue on the
// ELABORATED constant, then `valueRange` sets the signedness from the declared
// typespec); a PACKAGE/definition-homed one in
// `CompileHelper.cpp:3754-3772`, which sizes the store by `Bits(ts)` for EVERY
// const type and never calls `setSigned`.  So a package `int P = 16'd5` must
// be golden 32-wide and UNSIGNED where the module twin is 16-wide and SIGNED.
package y3p;
  localparam int            PIN = 16'd5;
  localparam signed [15:0]  PSG = 16'd5;
  localparam                PDU = 16'd5;
  localparam int            PIO = 16'o17;
  localparam logic signed [15:0] PLS = 16'o17;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
endpackage
module y3_home87;
  import y3p::*;
  localparam int            MIN = 16'd5;
  localparam signed [15:0]  MSG = 16'd5;
  localparam                MDU = 16'd5;
  // PACKAGE-homed, spelled BARE (imported) and QUALIFIED
  localparam y3p::t P = '{bail: 8'hxA, a: PIN, b: PSG, c: PDU, d: PIO,
                          e: PLS, f: y3p::PIN, g: y3p::PSG};
  // the MODULE-homed twins beside them
  localparam y3p::t M = '{bail: 8'hxA, a: MIN, b: MSG, c: MDU, d: MIN,
                          e: MSG, f: MDU, g: MIN};
  y3_sink #(.R(P)) s1();
  y3_sink #(.R(M)) s2();
endmodule
module y3_sink #(parameter y3p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule
