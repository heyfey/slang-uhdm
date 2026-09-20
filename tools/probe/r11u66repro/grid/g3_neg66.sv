// r11u66 arm g3 — THE VALUE HALF.  Which value rule does the ELABORATED
// pattern-operand fold use: pass 55's F2 (a unary minus writes the NEGATED
// OPERAND MAGNITUDE, every other signed answer writes the setter's own signed
// value), or the member-masked unsigned reading this walk writes today?
// Signed AND unsigned members, packed AND unpacked, so the member's own
// signedness is a control.
package q3;
  localparam int K = 5;
  localparam int unsigned KU = 5;
  typedef struct packed {
    logic signed [31:0] ms;   // -16'd5   unary minus over a BASED literal
    logic [31:0]        mu;   // -16'd5   the same onto an UNSIGNED member
    logic signed [31:0] nk;   // -K       unary minus over a name
    logic [31:0]        nku;  // -K       onto an UNSIGNED member
    logic signed [15:0] n16;  // 2 - 5    a NARROW signed member
    logic [15:0]        u16;  // 2 - 5    a NARROW unsigned member
    logic signed [7:0]  n8;   // 2 - 5    an 8-BIT signed member
    logic [7:0]         u8;   // 2 - 5    an 8-BIT unsigned member
    logic signed [63:0] n64;  // 2 - 5    a 64-BIT signed member
    logic [31:0]        z0;   // K - K    a ZERO out of an INT arm
    logic signed [31:0] mz;   // -0       unary minus over zero
    logic [31:0]        mm;   // -(-K)    a DOUBLE unary minus
    logic [31:0]        pu;   // K - KU   a mixed-signedness subtract
  } c3_t;
  localparam c3_t L3 = '{ms: -16'd5, mu: -16'd5, nk: -K, nku: -K,
                         n16: 2 - 5, u16: 2 - 5, n8: 2 - 5, u8: 2 - 5,
                         n64: 2 - 5, z0: K - K, mz: -0, mm: -(-K),
                         pu: K - KU};
endpackage
module g3_neg66 #(parameter q3::c3_t C = q3::L3)
                (output logic signed [31:0] o1, output logic [31:0] o2,
                 output logic signed [31:0] o3, output logic [31:0] o4,
                 output logic signed [15:0] o5, output logic [15:0] o6,
                 output logic signed [7:0] o7, output logic [7:0] o8,
                 output logic signed [63:0] o9, output logic [31:0] o10,
                 output logic signed [31:0] o11, output logic [31:0] o12,
                 output logic [31:0] o13);
  assign o1 = C.ms;  assign o2 = C.mu;  assign o3 = C.nk;   assign o4 = C.nku;
  assign o5 = C.n16; assign o6 = C.u16; assign o7 = C.n8;   assign o8 = C.u8;
  assign o9 = C.n64; assign o10 = C.z0; assign o11 = C.mz;  assign o12 = C.mm;
  assign o13 = C.pu;
  // the UNPACKED twin of the same question, module-local (r11u61's road)
  localparam int LK3 = 5;
  typedef struct { byte a; shortint b; int c; } u3_t;
  localparam u3_t U3 = '{a: 2 - 5, b: -LK3, c: LK3 * 2};
  logic signed [31:0] uo;
  assign uo = U3.c;
endmodule
