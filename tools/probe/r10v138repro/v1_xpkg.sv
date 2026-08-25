// V1 — CROSS-PACKAGE: the enum typedef lives in P1; the returning function
// lives in P2 which wildcard-imports P1.  The enumerator's parent scope is
// a Package, so the patch's home-walk says FOLD.  Does golden?
package v1p1;
   typedef enum { X_A, X_B, X_C } x_t;
   typedef enum int { Y_A = 5, Y_B = 9 } y_t;
endpackage

package v1p2;
   import v1p1::*;
   // free function in P2 returning P1's enumerator, written BARE
   function x_t f_wild();
      return X_B;
   endfunction
   function y_t f_wildy();
      return Y_B;
   endfunction
   class C2;
      extern function x_t m_oob();
   endclass
   function x_t C2::m_oob();
      return X_C;
   endfunction
endpackage

package v1p3;
   import v1p1::X_A;
   import v1p1::x_t;
   // EXPLICIT single-name import
   function x_t f_expl();
      return X_A;
   endfunction
endpackage

module v1top;
   v1p2::C2 c;
   v1p1::x_t a;
   v1p1::y_t b;
   v1p1::x_t d;
   initial begin
      a = v1p2::f_wild();
      b = v1p2::f_wildy();
      d = v1p3::f_expl();
   end
endmodule
