// r11u72 arm t2 — THE LEAF READ.  The producer's `get_value` reads the
// REDUCED operand's own value string, and a NAME reduces to the parameter's
// STORED value, which the producer computed with the SAME int64 table.  So a
// name hop must be followed into its initializer, not read off slang's typing
// of the name.  (x3_names `md` is the committed witness: `localparam MD =
// -16'd5` is golden INT:-5 and ours INT:65531.)  Each member read ONCE.
package q2;
  localparam           MD   = -16'd5;        // untyped: slang types it 16-bit
  localparam           MB   = -8'd3;         // ditto, 8-bit
  localparam int       OVF  = 2000000000 * 2;  // the INITIALIZER overflows int32
  localparam int       K    = 6;
  localparam bit [63:0] ONES = 64'hFFFFFFFFFFFFFFFF;
  localparam int       TWOHOP = OVF;          // a NAME reading an overflowing NAME
  typedef enum logic [3:0] { E_A = 4'd9, E_B = 4'd3 } e2_t;
  typedef struct packed {
    logic signed [31:0] a;   // MD          golden INT:-5
    logic signed [31:0] b;   // MD + 0      the name INSIDE an arm
    logic signed [31:0] c;   // MB          golden INT:-3
    logic [31:0]        d;   // OVF         the stored int64 4000000000
    logic [31:0]        e;   // TWOHOP      two hops to the same
    logic [63:0]        f;   // ONES - 1    int64 -1 - 1 = -2
    logic [31:0]        g;   // E_A * 2     an ENUM member leaf: 18
    logic [31:0]        h;   // K * 2       12   CONTROL
  } c2_t;
  localparam c2_t A2 = '{a: MD, b: MD + 0, c: MB, d: OVF, e: TWOHOP,
                         f: ONES - 1, g: E_A * 2, h: K * 2};
endpackage
module t2_leaf72 #(parameter q2::c2_t C = q2::A2)
                 (output logic signed [31:0] y0, output logic signed [31:0] y1,
                  output logic signed [31:0] y2, output logic [31:0] y3,
                  output logic [31:0] y4, output logic [63:0] y5,
                  output logic [31:0] y6, output logic [31:0] y7);
  assign y0 = C.a; assign y1 = C.b; assign y2 = C.c; assign y3 = C.d;
  assign y4 = C.e; assign y5 = C.f; assign y6 = C.g; assign y7 = C.h;
endmodule
