// r11u68 arm c1 — LAW B's GOLDEN GRID: every BASE letter x LITERAL WIDTH x
// MEMBER WIDTH x Lhs WIDTH at the elaborated cont_assign substitution.
// `adjustOpSize` (CompileHelper.cpp:5114-5172) writes cop->VpiSize(<member
// bits>) on EVERY operand it reaches, value untouched; `adjustSize`
// (CompileHelper.cpp:4065-4246) then re-sizes from THAT size, and its arms
// differ per encoding -- UINT masks to the Lhs, a BASED literal carrying its
// own int_typespec takes min(member, Lhs) with the digits UNTOUCHED, a
// vpiDecConst is never re-sized at all, and the rest follow the Lhs.
// Read at an Lhs NARROWER than, and WIDER than, every member.
package pc;
  localparam H16 = 16'hBEEF;
  localparam B16 = 16'b1010010111000011;
  localparam D16 = 16'd4660;
  localparam O16 = 16'o7654;
  typedef struct packed {
    logic [7:0] h4_m8;
    logic [15:0] h4_m16;
    logic [23:0] h4_m24;
    logic [7:0] h16_m8;
    logic [15:0] h16_m16;
    logic [23:0] h16_m24;
    logic [7:0] b4_m8;
    logic [15:0] b4_m16;
    logic [23:0] b4_m24;
    logic [7:0] b16_m8;
    logic [15:0] b16_m16;
    logic [23:0] b16_m24;
    logic [7:0] o4_m8;
    logic [15:0] o4_m16;
    logic [23:0] o4_m24;
    logic [7:0] o16_m8;
    logic [15:0] o16_m16;
    logic [23:0] o16_m24;
    logic [7:0] d4_m8;
    logic [15:0] d4_m16;
    logic [23:0] d4_m24;
    logic [7:0] d16_m8;
    logic [15:0] d16_m16;
    logic [23:0] d16_m24;
    logic [7:0] sh16_m8;
    logic [15:0] sh16_m16;
    logic [23:0] sh16_m24;
    logic [7:0] sd16_m8;
    logic [15:0] sd16_m16;
    logic [23:0] sd16_m24;
    logic [7:0] sb4_m8;
    logic [15:0] sb4_m16;
    logic [23:0] sb4_m24;
    logic [7:0] nh16;
    logic [7:0] nb16;
    logic [7:0] nd16;
    logic [7:0] no16;
    logic [23:0] nb16w;
    logic [23:0] nd16w;
  } cc_t;
  localparam cc_t LC = '{h4_m8: 4'hA, h4_m16: 4'hA, h4_m24: 4'hA, h16_m8: 16'hBEEF, h16_m16: 16'hBEEF, h16_m24: 16'hBEEF, b4_m8: 4'b1011, b4_m16: 4'b1011, b4_m24: 4'b1011, b16_m8: 16'b1010010111000011, b16_m16: 16'b1010010111000011, b16_m24: 16'b1010010111000011, o4_m8: 4'o5, o4_m16: 4'o5, o4_m24: 4'o5, o16_m8: 16'o7654, o16_m16: 16'o7654, o16_m24: 16'o7654, d4_m8: 4'd9, d4_m16: 4'd9, d4_m24: 4'd9, d16_m8: 16'd4660, d16_m16: 16'd4660, d16_m24: 16'd4660, sh16_m8: 16'shBEEF, sh16_m16: 16'shBEEF, sh16_m24: 16'shBEEF, sd16_m8: 16'sd4660, sd16_m16: 16'sd4660, sd16_m24: 16'sd4660, sb4_m8: 4'sb1011, sb4_m16: 4'sb1011, sb4_m24: 4'sb1011, nh16: H16, nb16: B16, nd16: D16, no16: O16, nb16w: B16, nd16w: D16};
endpackage
module narc #(parameter pc::cc_t C = pc::LC)
           (output logic [7:0] o_h4_m8, output logic [7:0] o_h4_m16, output logic [7:0] o_h4_m24, output logic [7:0] o_h16_m8, output logic [7:0] o_h16_m16, output logic [7:0] o_h16_m24, output logic [7:0] o_b4_m8, output logic [7:0] o_b4_m16, output logic [7:0] o_b4_m24, output logic [7:0] o_b16_m8, output logic [7:0] o_b16_m16, output logic [7:0] o_b16_m24, output logic [7:0] o_o4_m8, output logic [7:0] o_o4_m16, output logic [7:0] o_o4_m24, output logic [7:0] o_o16_m8, output logic [7:0] o_o16_m16, output logic [7:0] o_o16_m24, output logic [7:0] o_d4_m8, output logic [7:0] o_d4_m16, output logic [7:0] o_d4_m24, output logic [7:0] o_d16_m8, output logic [7:0] o_d16_m16, output logic [7:0] o_d16_m24, output logic [7:0] o_sh16_m8, output logic [7:0] o_sh16_m16, output logic [7:0] o_sh16_m24, output logic [7:0] o_sd16_m8, output logic [7:0] o_sd16_m16, output logic [7:0] o_sd16_m24, output logic [7:0] o_sb4_m8, output logic [7:0] o_sb4_m16, output logic [7:0] o_sb4_m24, output logic [7:0] o_nh16, output logic [7:0] o_nb16, output logic [7:0] o_nd16, output logic [7:0] o_no16, output logic [7:0] o_nb16w, output logic [7:0] o_nd16w);
  assign o_h4_m8 = C.h4_m8;
  assign o_h4_m16 = C.h4_m16;
  assign o_h4_m24 = C.h4_m24;
  assign o_h16_m8 = C.h16_m8;
  assign o_h16_m16 = C.h16_m16;
  assign o_h16_m24 = C.h16_m24;
  assign o_b4_m8 = C.b4_m8;
  assign o_b4_m16 = C.b4_m16;
  assign o_b4_m24 = C.b4_m24;
  assign o_b16_m8 = C.b16_m8;
  assign o_b16_m16 = C.b16_m16;
  assign o_b16_m24 = C.b16_m24;
  assign o_o4_m8 = C.o4_m8;
  assign o_o4_m16 = C.o4_m16;
  assign o_o4_m24 = C.o4_m24;
  assign o_o16_m8 = C.o16_m8;
  assign o_o16_m16 = C.o16_m16;
  assign o_o16_m24 = C.o16_m24;
  assign o_d4_m8 = C.d4_m8;
  assign o_d4_m16 = C.d4_m16;
  assign o_d4_m24 = C.d4_m24;
  assign o_d16_m8 = C.d16_m8;
  assign o_d16_m16 = C.d16_m16;
  assign o_d16_m24 = C.d16_m24;
  assign o_sh16_m8 = C.sh16_m8;
  assign o_sh16_m16 = C.sh16_m16;
  assign o_sh16_m24 = C.sh16_m24;
  assign o_sd16_m8 = C.sd16_m8;
  assign o_sd16_m16 = C.sd16_m16;
  assign o_sd16_m24 = C.sd16_m24;
  assign o_sb4_m8 = C.sb4_m8;
  assign o_sb4_m16 = C.sb4_m16;
  assign o_sb4_m24 = C.sb4_m24;
  assign o_nh16 = C.nh16;
  assign o_nb16 = C.nb16;
  assign o_nd16 = C.nd16;
  assign o_no16 = C.no16;
  assign o_nb16w = C.nb16w;
  assign o_nd16w = C.nd16w;
endmodule
module widc #(parameter pc::cc_t C = pc::LC)
           (output logic [31:0] o_h4_m8, output logic [31:0] o_h4_m16, output logic [31:0] o_h4_m24, output logic [31:0] o_h16_m8, output logic [31:0] o_h16_m16, output logic [31:0] o_h16_m24, output logic [31:0] o_b4_m8, output logic [31:0] o_b4_m16, output logic [31:0] o_b4_m24, output logic [31:0] o_b16_m8, output logic [31:0] o_b16_m16, output logic [31:0] o_b16_m24, output logic [31:0] o_o4_m8, output logic [31:0] o_o4_m16, output logic [31:0] o_o4_m24, output logic [31:0] o_o16_m8, output logic [31:0] o_o16_m16, output logic [31:0] o_o16_m24, output logic [31:0] o_d4_m8, output logic [31:0] o_d4_m16, output logic [31:0] o_d4_m24, output logic [31:0] o_d16_m8, output logic [31:0] o_d16_m16, output logic [31:0] o_d16_m24, output logic [31:0] o_sh16_m8, output logic [31:0] o_sh16_m16, output logic [31:0] o_sh16_m24, output logic [31:0] o_sd16_m8, output logic [31:0] o_sd16_m16, output logic [31:0] o_sd16_m24, output logic [31:0] o_sb4_m8, output logic [31:0] o_sb4_m16, output logic [31:0] o_sb4_m24, output logic [31:0] o_nh16, output logic [31:0] o_nb16, output logic [31:0] o_nd16, output logic [31:0] o_no16, output logic [31:0] o_nb16w, output logic [31:0] o_nd16w);
  assign o_h4_m8 = C.h4_m8;
  assign o_h4_m16 = C.h4_m16;
  assign o_h4_m24 = C.h4_m24;
  assign o_h16_m8 = C.h16_m8;
  assign o_h16_m16 = C.h16_m16;
  assign o_h16_m24 = C.h16_m24;
  assign o_b4_m8 = C.b4_m8;
  assign o_b4_m16 = C.b4_m16;
  assign o_b4_m24 = C.b4_m24;
  assign o_b16_m8 = C.b16_m8;
  assign o_b16_m16 = C.b16_m16;
  assign o_b16_m24 = C.b16_m24;
  assign o_o4_m8 = C.o4_m8;
  assign o_o4_m16 = C.o4_m16;
  assign o_o4_m24 = C.o4_m24;
  assign o_o16_m8 = C.o16_m8;
  assign o_o16_m16 = C.o16_m16;
  assign o_o16_m24 = C.o16_m24;
  assign o_d4_m8 = C.d4_m8;
  assign o_d4_m16 = C.d4_m16;
  assign o_d4_m24 = C.d4_m24;
  assign o_d16_m8 = C.d16_m8;
  assign o_d16_m16 = C.d16_m16;
  assign o_d16_m24 = C.d16_m24;
  assign o_sh16_m8 = C.sh16_m8;
  assign o_sh16_m16 = C.sh16_m16;
  assign o_sh16_m24 = C.sh16_m24;
  assign o_sd16_m8 = C.sd16_m8;
  assign o_sd16_m16 = C.sd16_m16;
  assign o_sd16_m24 = C.sd16_m24;
  assign o_sb4_m8 = C.sb4_m8;
  assign o_sb4_m16 = C.sb4_m16;
  assign o_sb4_m24 = C.sb4_m24;
  assign o_nh16 = C.nh16;
  assign o_nb16 = C.nb16;
  assign o_nd16 = C.nd16;
  assign o_no16 = C.no16;
  assign o_nb16w = C.nb16w;
  assign o_nd16w = C.nd16w;
endmodule
module c1_stamp68 (output logic [7:0] n_h4_m8, output logic [7:0] n_h4_m16, output logic [7:0] n_h4_m24, output logic [7:0] n_h16_m8, output logic [7:0] n_h16_m16, output logic [7:0] n_h16_m24, output logic [7:0] n_b4_m8, output logic [7:0] n_b4_m16, output logic [7:0] n_b4_m24, output logic [7:0] n_b16_m8, output logic [7:0] n_b16_m16, output logic [7:0] n_b16_m24, output logic [7:0] n_o4_m8, output logic [7:0] n_o4_m16, output logic [7:0] n_o4_m24, output logic [7:0] n_o16_m8, output logic [7:0] n_o16_m16, output logic [7:0] n_o16_m24, output logic [7:0] n_d4_m8, output logic [7:0] n_d4_m16, output logic [7:0] n_d4_m24, output logic [7:0] n_d16_m8, output logic [7:0] n_d16_m16, output logic [7:0] n_d16_m24, output logic [7:0] n_sh16_m8, output logic [7:0] n_sh16_m16, output logic [7:0] n_sh16_m24, output logic [7:0] n_sd16_m8, output logic [7:0] n_sd16_m16, output logic [7:0] n_sd16_m24, output logic [7:0] n_sb4_m8, output logic [7:0] n_sb4_m16, output logic [7:0] n_sb4_m24, output logic [7:0] n_nh16, output logic [7:0] n_nb16, output logic [7:0] n_nd16, output logic [7:0] n_no16, output logic [7:0] n_nb16w, output logic [7:0] n_nd16w, output logic [31:0] w_h4_m8, output logic [31:0] w_h4_m16, output logic [31:0] w_h4_m24, output logic [31:0] w_h16_m8, output logic [31:0] w_h16_m16, output logic [31:0] w_h16_m24, output logic [31:0] w_b4_m8, output logic [31:0] w_b4_m16, output logic [31:0] w_b4_m24, output logic [31:0] w_b16_m8, output logic [31:0] w_b16_m16, output logic [31:0] w_b16_m24, output logic [31:0] w_o4_m8, output logic [31:0] w_o4_m16, output logic [31:0] w_o4_m24, output logic [31:0] w_o16_m8, output logic [31:0] w_o16_m16, output logic [31:0] w_o16_m24, output logic [31:0] w_d4_m8, output logic [31:0] w_d4_m16, output logic [31:0] w_d4_m24, output logic [31:0] w_d16_m8, output logic [31:0] w_d16_m16, output logic [31:0] w_d16_m24, output logic [31:0] w_sh16_m8, output logic [31:0] w_sh16_m16, output logic [31:0] w_sh16_m24, output logic [31:0] w_sd16_m8, output logic [31:0] w_sd16_m16, output logic [31:0] w_sd16_m24, output logic [31:0] w_sb4_m8, output logic [31:0] w_sb4_m16, output logic [31:0] w_sb4_m24, output logic [31:0] w_nh16, output logic [31:0] w_nb16, output logic [31:0] w_nd16, output logic [31:0] w_no16, output logic [31:0] w_nb16w, output logic [31:0] w_nd16w);
  narc u_n (.o_h4_m8(n_h4_m8), .o_h4_m16(n_h4_m16), .o_h4_m24(n_h4_m24), .o_h16_m8(n_h16_m8), .o_h16_m16(n_h16_m16), .o_h16_m24(n_h16_m24), .o_b4_m8(n_b4_m8), .o_b4_m16(n_b4_m16), .o_b4_m24(n_b4_m24), .o_b16_m8(n_b16_m8), .o_b16_m16(n_b16_m16), .o_b16_m24(n_b16_m24), .o_o4_m8(n_o4_m8), .o_o4_m16(n_o4_m16), .o_o4_m24(n_o4_m24), .o_o16_m8(n_o16_m8), .o_o16_m16(n_o16_m16), .o_o16_m24(n_o16_m24), .o_d4_m8(n_d4_m8), .o_d4_m16(n_d4_m16), .o_d4_m24(n_d4_m24), .o_d16_m8(n_d16_m8), .o_d16_m16(n_d16_m16), .o_d16_m24(n_d16_m24), .o_sh16_m8(n_sh16_m8), .o_sh16_m16(n_sh16_m16), .o_sh16_m24(n_sh16_m24), .o_sd16_m8(n_sd16_m8), .o_sd16_m16(n_sd16_m16), .o_sd16_m24(n_sd16_m24), .o_sb4_m8(n_sb4_m8), .o_sb4_m16(n_sb4_m16), .o_sb4_m24(n_sb4_m24), .o_nh16(n_nh16), .o_nb16(n_nb16), .o_nd16(n_nd16), .o_no16(n_no16), .o_nb16w(n_nb16w), .o_nd16w(n_nd16w));
  widc u_w (.o_h4_m8(w_h4_m8), .o_h4_m16(w_h4_m16), .o_h4_m24(w_h4_m24), .o_h16_m8(w_h16_m8), .o_h16_m16(w_h16_m16), .o_h16_m24(w_h16_m24), .o_b4_m8(w_b4_m8), .o_b4_m16(w_b4_m16), .o_b4_m24(w_b4_m24), .o_b16_m8(w_b16_m8), .o_b16_m16(w_b16_m16), .o_b16_m24(w_b16_m24), .o_o4_m8(w_o4_m8), .o_o4_m16(w_o4_m16), .o_o4_m24(w_o4_m24), .o_o16_m8(w_o16_m8), .o_o16_m16(w_o16_m16), .o_o16_m24(w_o16_m24), .o_d4_m8(w_d4_m8), .o_d4_m16(w_d4_m16), .o_d4_m24(w_d4_m24), .o_d16_m8(w_d16_m8), .o_d16_m16(w_d16_m16), .o_d16_m24(w_d16_m24), .o_sh16_m8(w_sh16_m8), .o_sh16_m16(w_sh16_m16), .o_sh16_m24(w_sh16_m24), .o_sd16_m8(w_sd16_m8), .o_sd16_m16(w_sd16_m16), .o_sd16_m24(w_sd16_m24), .o_sb4_m8(w_sb4_m8), .o_sb4_m16(w_sb4_m16), .o_sb4_m24(w_sb4_m24), .o_nh16(w_nh16), .o_nb16(w_nb16), .o_nd16(w_nd16), .o_no16(w_no16), .o_nb16w(w_nb16w), .o_nd16w(w_nd16w));
endmodule
