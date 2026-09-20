// v11u68 ADVERSARIAL arm v3 — LAW B's UNCOVERED FACES.  The widened member
// stamp now reaches DEC / BIN / HEX / OCT / INT / STRING / SCALAR operands, so
// every Lhs shape where `caLhsAdjustBind106` FAILS (a bit-select, a
// part-select, an indexed part-select, an unpacked-array element) now keeps
// the MEMBER width where the literal width used to stand.  Plus the setter
// kinds `c1_stamp68` does not carry: '1/'0/'x, an unsized decimal, an
// expression, a concatenation, a string, an enum member, a negative, and a
// NAME whose parameter is LOGIC-typed rather than untyped.
package pv;
  localparam        UD16 = 16'd4660;      // untyped -> int typespec
  localparam logic [15:0] LD16 = 16'd4660;  // LOGIC-typed name
  localparam logic [15:0] LB16 = 16'b1010010111000011;
  localparam logic [15:0] LH16 = 16'hBEEF;
  localparam int unsigned KU = 6;
  typedef enum logic [7:0] { E_A = 8'd9 } e_t;
  typedef struct packed {
    logic [7:0]  d16;    // 16'd4660 on an 8-bit member
    logic [15:0] d16w;   // 16'd4660 on a 16-bit member
    logic [23:0] d16x;   // 16'd4660 on a 24-bit member
    logic [7:0]  b16;    // 16'b... on an 8-bit member
    logic [7:0]  h16;    // 16'h... on an 8-bit member
    logic [7:0]  o16;    // 16'o... on an 8-bit member
    logic [7:0]  ones;   // '1
    logic [7:0]  zers;   // '0
    logic [7:0]  unsz;   // an UNSIZED decimal 5
    logic [7:0]  expr;   // KU + 1
    logic [7:0]  cat;    // {4'd1, 4'd2}
    logic [23:0] str;    // "abc"
    logic [7:0]  enm;    // E_A
    logic signed [7:0] neg;  // -3
    logic [7:0]  nld;    // a LOGIC-typed name whose init is 'd
    logic [7:0]  nlb;    // a LOGIC-typed name whose init is 'b
    logic [7:0]  nlh;    // a LOGIC-typed name whose init is 'h
    logic [7:0]  nud;    // an UNTYPED name whose init is 'd
  } pv_t;
  localparam pv_t LV = '{d16: 16'd4660, d16w: 16'd4660, d16x: 16'd4660,
                         b16: 16'b1010010111000011, h16: 16'hBEEF, o16: 16'o7654,
                         ones: '1, zers: '0, unsz: 5, expr: KU + 1,
                         cat: {4'd1, 4'd2}, str: "abc", enm: E_A, neg: -3,
                         nld: LD16, nlb: LB16, nlh: LH16, nud: UD16};
endpackage
// WHOLE-NAME Lhs, 8 bits (adjustSize runs)
module wn8 #(parameter pv::pv_t C = pv::LV)
  (output logic [7:0] a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18);
  assign a1=C.d16; assign a2=C.d16w; assign a3=C.d16x; assign a4=C.b16;
  assign a5=C.h16; assign a6=C.o16; assign a7=C.ones; assign a8=C.zers;
  assign a9=C.unsz; assign a10=C.expr; assign a11=C.cat; assign a12=C.str;
  assign a13=C.enm; assign a14=C.neg; assign a15=C.nld; assign a16=C.nlb;
  assign a17=C.nlh; assign a18=C.nud;
endmodule
// WHOLE-NAME Lhs, 32 bits
module wn32 #(parameter pv::pv_t C = pv::LV)
  (output logic [31:0] a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18);
  assign a1=C.d16; assign a2=C.d16w; assign a3=C.d16x; assign a4=C.b16;
  assign a5=C.h16; assign a6=C.o16; assign a7=C.ones; assign a8=C.zers;
  assign a9=C.unsz; assign a10=C.expr; assign a11=C.cat; assign a12=C.str;
  assign a13=C.enm; assign a14=C.neg; assign a15=C.nld; assign a16=C.nlb;
  assign a17=C.nlh; assign a18=C.nud;
endmodule
// BIT-SELECT / PART-SELECT / INDEXED PART-SELECT / UNPACKED-ELEMENT Lhs:
// `writeCont_assign` finds NO whole-name typespec, so `adjustSize` returns at
// once and the MEMBER width stands.
module sel #(parameter pv::pv_t C = pv::LV)
  (output logic [31:0] b1, output logic [31:0] b2, output logic [31:0] b3,
   output logic [7:0] u1 [0:1], output logic [31:0] b4, output logic [31:0] b5,
   output logic [31:0] b6, output logic [31:0] b7);
  assign b1[3] = C.d16;      // bit-select
  assign b2[15:8] = C.d16;   // part-select
  assign b3[8 +: 8] = C.b16; // indexed part-select
  assign u1[0] = C.d16;      // unpacked-array element
  assign b4[7:0] = C.h16;
  assign b5[7:0] = C.o16;
  assign b6[7:0] = C.str;
  assign b7[7:0] = C.nud;
endmodule
module v3_lawb68
  (output logic [7:0] n1,n2,n3,n4,n5,n6,n7,n8,n9,n10,n11,n12,n13,n14,n15,n16,n17,n18,
   output logic [31:0] w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15,w16,w17,w18,
   output logic [31:0] s1, output logic [31:0] s2, output logic [31:0] s3,
   output logic [7:0] s4 [0:1], output logic [31:0] s5, output logic [31:0] s6,
   output logic [31:0] s7, output logic [31:0] s8);
  wn8  u_n (.a1(n1),.a2(n2),.a3(n3),.a4(n4),.a5(n5),.a6(n6),.a7(n7),.a8(n8),.a9(n9),
            .a10(n10),.a11(n11),.a12(n12),.a13(n13),.a14(n14),.a15(n15),.a16(n16),.a17(n17),.a18(n18));
  wn32 u_w (.a1(w1),.a2(w2),.a3(w3),.a4(w4),.a5(w5),.a6(w6),.a7(w7),.a8(w8),.a9(w9),
            .a10(w10),.a11(w11),.a12(w12),.a13(w13),.a14(w14),.a15(w15),.a16(w16),.a17(w17),.a18(w18));
  sel  u_s (.b1(s1),.b2(s2),.b3(s3),.u1(s4),.b4(s5),.b5(s6),.b6(s7),.b7(s8));
endmodule
