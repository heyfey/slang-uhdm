// V7 — the shapes left over: an anonymous enum inside a struct typedef, a
// parameter-valued member init, a macro-written reference, a range member
// reached from an out-of-body class method (the fix's other listing), and a
// range member in an IMPORT CLONE.
`define RET_IT(x) return x
package v7a;
   parameter int PV = 6;
   typedef struct packed { bit b; } s_t;
   typedef enum { SE_A, SE_B } se_t;                 // control
   typedef enum int { PZ_A = PV, PZ_B }  pz_t;       // parameter-valued init
   typedef enum { QR_A[2], QR_B }        qr_t;       // range + a plain member
   function se_t f_macro(); `RET_IT(SE_B); endfunction
   function pz_t f_param();  return PZ_A; endfunction
   function pz_t f_paramb(); return PZ_B; endfunction
   function qr_t f_rng();    return QR_A1; endfunction
   function qr_t f_plain();  return QR_B;  endfunction
   class RC;
      extern function qr_t m_rng();
      extern function se_t m_plain();
   endclass
   function qr_t RC::m_rng();   return QR_A0; endfunction
   function se_t RC::m_plain(); return SE_A;  endfunction
endpackage

package v7b;
   import v7a::*;
   function v7a::qr_t c_rng();   return QR_A1; endfunction
   function v7a::se_t c_plain(); return SE_B;  endfunction
endpackage

module v7top;
   v7a::RC rc;
   v7a::se_t s; v7a::pz_t p; v7a::qr_t q;
   initial begin
      s = v7a::f_macro(); p = v7a::f_param(); p = v7a::f_paramb();
      q = v7a::f_rng(); q = v7a::f_plain();
      rc = new(); q = rc.m_rng(); s = rc.m_plain();
      q = v7b::c_rng(); s = v7b::c_plain();
   end
endmodule
