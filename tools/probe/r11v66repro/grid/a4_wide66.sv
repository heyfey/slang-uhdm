// v11u66 adversarial arm a4 — THE EDGES OF THE DIGIT WRITER.
// >64-bit values, x/z values, a real operand, a division by zero: every one
// must leave the mint's own answer standing (an abstention), never write
// garbage digits.
package qa4;
  localparam logic [95:0] W  = 96'd5;
  localparam logic [31:0] XV = 32'bx;
  localparam int          K  = 6;
  typedef struct packed {
    logic [95:0] a;   // W * 2      96-bit product -- does not fit int64
    logic [95:0] b;   // W - 10     96-bit, "negative" -- does not fit
    logic [31:0] c;   // K - 1      control, fits
    logic [63:0] d;   // 64'sh8000000000000000 - 1   int64 MIN - 1 (wraps)
    logic [31:0] e;   // K * 0      zero out of an INT arm (control)
  } ca4_t;
  localparam ca4_t A4 = '{a: W*2, b: W-10, c: K-1,
                          d: 64'sh8000000000000000 - 1, e: K*0};
endpackage
module a4_wide66 #(parameter qa4::ca4_t C = qa4::A4)
                 (output logic [95:0] y0, output logic [95:0] y1,
                  output logic [31:0] y2, output logic [63:0] y3,
                  output logic [31:0] y4);
  assign y0 = C.a; assign y1 = C.b; assign y2 = C.c; assign y3 = C.d;
  assign y4 = C.e;
endmodule
