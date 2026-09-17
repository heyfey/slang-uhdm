// r11u56 arm e2 — THE THREE MOVING FACES ACROSS MEMBER WIDTH x Lhs WIDTH.
// Each member is read EXACTLY ONCE PER INSTANCE (the cross-assign sharing
// confound stays out); three modules give the narrow / equal / wide Lhs
// directions.  Member widths 8 / 32 / 64 / 96 cross the unbased-unsized,
// signed-negative and enum setters.
package p;
  typedef enum logic [3:0] { E_A = 4'd2, E_B = 4'd9 } e_t;
  typedef struct packed {
    logic [7:0]  a8;    // '1 on an 8-bit member
    logic [31:0] a32;   // '1 on a 32-bit member
    logic [63:0] a64;   // '1 on a 64-bit member
    logic [95:0] a96;   // '1 on a 96-bit member (> 64: the BIN arm)
    logic [31:0] z0;    // '0
    logic [31:0] zx;    // 'x
    logic [31:0] zz;    // 'z
    int          sn;    // -1 on a signed member
    e_t          ev;    // enum member
  } cfg_t;
  localparam cfg_t LIT = '{a8: '1, a32: '1, a64: '1, a96: '1,
                           z0: '0, zx: 'x, zz: 'z, sn: -1, ev: E_B};
endpackage
module nar #(parameter p::cfg_t C = p::LIT)
           (output logic [7:0] o1, output logic [7:0] o2,
            output logic [7:0] o3, output logic [7:0] o4,
            output logic [7:0] o5, output logic [7:0] o6,
            output logic [7:0] o7, output logic signed [7:0] o8,
            output logic [7:0] o9);
  assign o1 = C.a8;  assign o2 = C.a32; assign o3 = C.a64; assign o4 = C.a96;
  assign o5 = C.z0;  assign o6 = C.zx;  assign o7 = C.zz;  assign o8 = C.sn;
  assign o9 = C.ev;
endmodule
module eq_ #(parameter p::cfg_t C = p::LIT)
           (output logic [7:0] o1, output logic [31:0] o2,
            output logic [63:0] o3, output logic [95:0] o4,
            output logic [31:0] o5, output logic [31:0] o6,
            output logic [31:0] o7, output logic signed [31:0] o8,
            output logic [3:0] o9);
  assign o1 = C.a8;  assign o2 = C.a32; assign o3 = C.a64; assign o4 = C.a96;
  assign o5 = C.z0;  assign o6 = C.zx;  assign o7 = C.zz;  assign o8 = C.sn;
  assign o9 = C.ev;
endmodule
module wid #(parameter p::cfg_t C = p::LIT)
           (output logic [95:0] o1, output logic [95:0] o2,
            output logic [95:0] o3, output logic [127:0] o4,
            output logic [63:0] o5, output logic [63:0] o6,
            output logic [63:0] o7, output logic signed [63:0] o8,
            output logic [63:0] o9);
  assign o1 = C.a8;  assign o2 = C.a32; assign o3 = C.a64; assign o4 = C.a96;
  assign o5 = C.z0;  assign o6 = C.zx;  assign o7 = C.zz;  assign o8 = C.sn;
  assign o9 = C.ev;
endmodule
module dut (output logic [7:0] n1, output logic [7:0] n2, output logic [7:0] n3,
            output logic [7:0] n4, output logic [7:0] n5, output logic [7:0] n6,
            output logic [7:0] n7, output logic signed [7:0] n8, output logic [7:0] n9,
            output logic [7:0] e1, output logic [31:0] e2, output logic [63:0] e3,
            output logic [95:0] e4, output logic [31:0] e5, output logic [31:0] e6,
            output logic [31:0] e7, output logic signed [31:0] e8, output logic [3:0] e9,
            output logic [95:0] w1, output logic [95:0] w2, output logic [95:0] w3,
            output logic [127:0] w4, output logic [63:0] w5, output logic [63:0] w6,
            output logic [63:0] w7, output logic signed [63:0] w8, output logic [63:0] w9);
  nar u_n (.o1(n1), .o2(n2), .o3(n3), .o4(n4), .o5(n5), .o6(n6), .o7(n7), .o8(n8), .o9(n9));
  eq_ u_e (.o1(e1), .o2(e2), .o3(e3), .o4(e4), .o5(e5), .o6(e6), .o7(e7), .o8(e8), .o9(e9));
  wid u_w (.o1(w1), .o2(w2), .o3(w3), .o4(w4), .o5(w5), .o6(w6), .o7(w7), .o8(w8), .o9(w9));
endmodule
