// v11u56 ADVERSARIAL arm x2 — THE ENUM ARM IS UNCONDITIONAL.  caSubstLeafCt56
// answers vpiIntConst for EVERY EnumValue symbol, BEFORE the based-literal
// fence can see the member's own literal.  Surelog's LValue::vpiValType
// (Value.cpp:952) maps Type::Binary -> vpiBinaryConst and Type::Unsigned ->
// vpiUIntConst, so an enum member written in BINARY or as an unsized decimal
// is the place a blanket vpiIntConst can be WRONG.
package p;
  localparam int K = 6;
  typedef enum logic [3:0] { D_A = 4'd2, D_B = 4'd9 }        ed_t;  // control
  typedef enum logic [3:0] { B_A = 4'b0010, B_B = 4'b1001 }  eb_t;  // BINARY
  typedef enum logic [3:0] { H_A = 4'hA, H_B = 4'hC }        eh_t;  // HEX
  typedef enum logic [3:0] { O_A = 4'o3, O_B = 4'o7 }        eo_t;  // OCTAL
  typedef enum logic [3:0] { U_A = 2, U_B = 9 }              eu_t;  // UNSIZED dec
  typedef enum int         { N_A = -3, N_B = -7 }            en_t;  // NEGATIVE
  typedef enum logic [15:0]{ W_A = 16'hBEEF, W_B = 16'hCAFE } ew_t; // WIDE HEX
  typedef enum logic [7:0] { X_A = K + 1, X_B = K * 2 }      ex_t;  // EXPRESSION
  typedef enum logic [3:0] { S_A = 4'sd5, S_B = 4'sd3 }      es_t;  // SIGNED dec
  typedef enum logic [3:0] { I_A, I_B, I_C }                 ei_t;  // IMPLICIT (no init)
  typedef enum logic [15:0]{ M_A = 16'd7, M_B = 16'd40 }     em_t;  // WIDE based dec
  typedef enum logic [7:0] { R_A = K, R_B = K + 1 }          er_t;  // a NAME init
  typedef struct packed {
    ed_t d; eb_t b; eh_t h; eo_t o; eu_t u; en_t n; ew_t w; ex_t x; es_t s;
    ei_t i; em_t m; er_t r;
  } cfg_t;
  localparam cfg_t LIT = '{d: D_B, b: B_B, h: H_B, o: O_B, u: U_B,
                           n: N_B, w: W_B, x: X_B, s: S_B,
                           i: I_C, m: M_B, r: R_A};
endpackage
module dut #(parameter p::cfg_t C = p::LIT)
           (output logic [31:0] od, output logic [31:0] ob,
            output logic [31:0] oh, output logic [31:0] oo,
            output logic [31:0] ou, output logic signed [31:0] on_,
            output logic [31:0] ow, output logic [31:0] ox,
            output logic [31:0] os, output logic [31:0] oi,
            output logic [31:0] om, output logic [31:0] orr);
  assign od = C.d;  assign ob = C.b;  assign oh = C.h;  assign oo = C.o;
  assign ou = C.u;  assign on_ = C.n; assign ow = C.w;  assign ox = C.x;
  assign os = C.s;  assign oi = C.i;  assign om = C.m;  assign orr = C.r;
endmodule
