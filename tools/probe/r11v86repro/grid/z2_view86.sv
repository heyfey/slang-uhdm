// VERIFIER arm z2 — THE DEF VIEW AND THE GENERATE-DECLARED HOP.  Golden's
// module route only answers when `instance->getValue(name)` is VALID; a hop
// the instance's simple Value store does not carry falls to the CLONE and
// keeps `DEC:`.  Two shapes the landed grid never put a hop into:
//   * a NON-TOP module (so both the DEF view and the ELABORATED view of the
//     same pattern are emitted) whose pattern hops a module localparam;
//   * a parameter DECLARED INSIDE a generate block, hopped from a pattern in
//     the same generate block.
package z2p;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
  } t;
endpackage
module z2_view86;
  z2_mid m1();
  z2_mid m2();
endmodule
module z2_mid;
  localparam ZMD = 16'd5;
  localparam ZMO = 16'o5;
  localparam z2p::t ZQ = '{bail: 8'hxA, a: ZMD, b: ZMO, c: 16'd5};
  z2_sink #(.R(ZQ)) s1();
  if (1) begin : g
    localparam ZGD = 16'd6;
    localparam ZGO = 16'o6;
    localparam z2p::t ZG = '{bail: 8'hxA, a: ZGD, b: ZGO, c: 16'd6};
    z2_sink #(.R(ZG)) s2();
  end
endmodule
module z2_sink #(parameter z2p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule
