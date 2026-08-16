// r10uvm76 arm b2 — THE GATE'S NEGATIVE.  Byte-for-byte b1 with the method
// written IN BODY.  Same class, same enum, same names, same importing module.
// The method resolves at CLASS scope, so the enum constants are visible and
// golden binds the real enum_const.  If golden nets these too, "out-of-body"
// is not the gate and the law is wrong.
package p76b;
  typedef enum {G_X, G_Y} g76_t;
  class c76;
    typedef enum {E_A, E_B, E_C} e76_t;
    e76_t m;
    // IN-BODY definition: compiled at CLASS scope.
    function int inbf(int k);
      int r;
      r = 0;
      if (m == E_A) r = r + 1;
      if (m == E_B) r = r + 2;
      if (m == E_A) r = r + 4;
      if (k == G_X) r = r + 8;
      return r;
    endfunction
  endclass
endpackage
import p76b::*;
module top76b;
  c76 c;
  int r;
  initial begin
    c = new();
    r = c.inbf(1);
  end
endmodule
