// r11u56 arm e3 — THE BASE-LETTER FENCE.  Every based literal form (h/b/o/d,
// plain and SIGNED) plus a NAME reading one, at member widths that make the
// producer's adjustSize shrink, keep and widen.  These cells must be
// IDENTICAL law-vs-pristine: the encoding law abstains on a based literal.
package p;
  localparam D16 = 16'd40;
  localparam H16 = 16'h28;
  localparam B16 = 16'b1010_0101_1100_0011;
  localparam O16 = 16'o7654;
  typedef struct packed {
    logic [15:0] h;     // 16'hBEEF
    logic [15:0] b;     // 16'b...
    logic [15:0] o;     // 16'o...
    logic [15:0] d;     // 16'd4660
    logic [15:0] sh;    // 16'shBEEF (signed based)
    logic [15:0] sd;    // 16'sd4660
    logic [7:0]  nh;    // a 16-bit hex literal on an 8-bit member
    logic [7:0]  nb;    // a 16-bit bin literal on an 8-bit member
    logic [7:0]  nd;    // a 16-bit dec literal on an 8-bit member
    logic [15:0] rd;    // a NAME whose init is 'd
    logic [15:0] rh;    // a NAME whose init is 'h
    logic [15:0] rb;    // a NAME whose init is 'b
    logic [15:0] ro;    // a NAME whose init is 'o
  } cfg_t;
  localparam cfg_t LIT = '{h: 16'hBEEF, b: 16'b1010_0101_1100_0011,
                           o: 16'o7654, d: 16'd4660, sh: 16'shBEEF,
                           sd: 16'sd4660, nh: 16'hBEEF,
                           nb: 16'b1010_0101_1100_0011, nd: 16'd4660,
                           rd: D16, rh: H16, rb: B16, ro: O16};
endpackage
module nar #(parameter p::cfg_t C = p::LIT)
           (output logic [7:0] o1, output logic [7:0] o2, output logic [7:0] o3,
            output logic [7:0] o4, output logic [7:0] o5, output logic [7:0] o6,
            output logic [7:0] o7, output logic [7:0] o8, output logic [7:0] o9,
            output logic [7:0] o10, output logic [7:0] o11, output logic [7:0] o12,
            output logic [7:0] o13);
  assign o1 = C.h;   assign o2 = C.b;  assign o3 = C.o;  assign o4 = C.d;
  assign o5 = C.sh;  assign o6 = C.sd; assign o7 = C.nh; assign o8 = C.nb;
  assign o9 = C.nd;  assign o10 = C.rd; assign o11 = C.rh; assign o12 = C.rb;
  assign o13 = C.ro;
endmodule
module wid #(parameter p::cfg_t C = p::LIT)
           (output logic [31:0] o1, output logic [31:0] o2, output logic [31:0] o3,
            output logic [31:0] o4, output logic [31:0] o5, output logic [31:0] o6,
            output logic [31:0] o7, output logic [31:0] o8, output logic [31:0] o9,
            output logic [31:0] o10, output logic [31:0] o11, output logic [31:0] o12,
            output logic [31:0] o13);
  assign o1 = C.h;   assign o2 = C.b;  assign o3 = C.o;  assign o4 = C.d;
  assign o5 = C.sh;  assign o6 = C.sd; assign o7 = C.nh; assign o8 = C.nb;
  assign o9 = C.nd;  assign o10 = C.rd; assign o11 = C.rh; assign o12 = C.rb;
  assign o13 = C.ro;
endmodule
module dut (output logic [7:0] n1, output logic [7:0] n2, output logic [7:0] n3,
            output logic [7:0] n4, output logic [7:0] n5, output logic [7:0] n6,
            output logic [7:0] n7, output logic [7:0] n8, output logic [7:0] n9,
            output logic [7:0] n10, output logic [7:0] n11, output logic [7:0] n12,
            output logic [7:0] n13,
            output logic [31:0] w1, output logic [31:0] w2, output logic [31:0] w3,
            output logic [31:0] w4, output logic [31:0] w5, output logic [31:0] w6,
            output logic [31:0] w7, output logic [31:0] w8, output logic [31:0] w9,
            output logic [31:0] w10, output logic [31:0] w11, output logic [31:0] w12,
            output logic [31:0] w13);
  nar u_n (.o1(n1), .o2(n2), .o3(n3), .o4(n4), .o5(n5), .o6(n6), .o7(n7),
           .o8(n8), .o9(n9), .o10(n10), .o11(n11), .o12(n12), .o13(n13));
  wid u_w (.o1(w1), .o2(w2), .o3(w3), .o4(w4), .o5(w5), .o6(w6), .o7(w7),
           .o8(w8), .o9(w9), .o10(w10), .o11(w11), .o12(w12), .o13(w13));
endmodule
