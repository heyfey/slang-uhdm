// b01: every unsized-based literal shape, one home, module that is a TOP and
// a module that is INSTANTIATED (so both the def copy and the elab copy exist).
package b01_pkg;
  parameter B_H   = 'h1a;
  parameter B_HU  = 'H1A;
  parameter B_B   = 'b1010;
  parameter B_BU  = 'B1010;
  parameter B_O   = 'o777;
  parameter B_OU  = 'O777;
  parameter B_D   = 'd99;
  parameter B_DU  = 'D99;
  parameter B_HX  = 'hx;
  parameter B_HXU = 'hX;
  parameter B_HZ  = 'hz;
  parameter B_BX  = 'bx;
  parameter B_BZ  = 'bz;
  parameter B_OZ  = 'oz;
  parameter B_DX  = 'dx;
  parameter B_DZ  = 'dz;
  parameter B_HQ  = 'h?;
  parameter B_BQ  = 'b1?0?;
  parameter B_US1 = 'h1_a_b;
  parameter B_US2 = 'b1_0_1_0;
  parameter B_ZERO_B = 'b0;
  parameter B_ONE_B  = 'b1;
  parameter B_ZERO_BU= 'B0;
  parameter B_ONE_BU = 'B1;
  parameter B_ZERO_H = 'h0;
  parameter B_ZERO_O = 'o0;
  parameter B_ZERO_D = 'd0;
  parameter B_ONE_H  = 'h1;
  parameter B_ONE_D  = 'd1;
  parameter B_BIG    = 'h123456789abcdef;
  parameter B_S_H  = 'sh1a;
  parameter B_S_HU = 'SH1A;
  parameter B_S_B  = 'sb1010;
  parameter B_S_O  = 'so777;
  parameter B_S_D  = 'sd99;
  parameter B_S_HX = 'shx;
endpackage
module b01_use;
  import b01_pkg::*;
  initial $display(B_H, B_B, B_O, B_D, B_HX, B_ZERO_B, B_S_H, B_BIG);
endmodule
module b01_top;
  b01_use u1();
  b01_use u2();
endmodule
