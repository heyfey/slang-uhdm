// r11u87 arm y7 — THE REST OF THE DECLARED-SIGNED FACE: an initializer that is
// an OPERATION, a negation, a system call, a type cast, a hex leaf under a
// signed declaration, and the two context roads r11v86's RV86-2 named
// (`'{default: HOP}` and a packed-array element) where the landed encoding law
// abstains and this pass must abstain with it.
package y7p;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
  typedef struct packed { logic [23:0] x; logic [23:0] y; } in7;
  typedef struct packed { logic [23:0] bail; in7 n; } nest7;
endpackage
module y7_msc87;
  localparam int               XOP = 16'd9 + 16'd1;
  localparam int               XNG = -16'd5;
  localparam int               XCL = $clog2(8);
  localparam int               XCS = int'(3);
  localparam logic signed [15:0] XHX = 16'h5;
  localparam bit signed [15:0] XBS = 16'o17;
  localparam int               XIN = 16'd5;
  localparam y7p::t A = '{bail: 8'hxA, a: XOP, b: XNG, c: XCL, d: XCS,
                          e: XHX, f: XBS, g: XIN};
  localparam y7p::t D = '{default: XIN};
  localparam y7p::nest7 N = '{bail: 8'hxA, n: '{x: XIN, y: XBS}};
  typedef logic [23:0] arr7 [0:2];
  localparam arr7 AR = '{XIN, XBS, XIN};
  y7_sink #(.R(A)) s1();
  y7_sink #(.R(D)) s2();
endmodule
module y7_sink #(parameter y7p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule
