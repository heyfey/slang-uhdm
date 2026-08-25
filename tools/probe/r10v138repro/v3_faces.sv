// V3 — the FACE grid the brief names: bare return / ternary arms / cast /
// rhs / call argument / comparison / case item / property init / localparam
// init / concatenation operand — all in the FOLD WINDOW (package free fn and
// out-of-body method).
package v3p;
   typedef enum { F_A, F_B, F_C } f_t;
   typedef enum bit [3:0] { G_A = 4'hB, G_B = 4'h2 } g_t;

   function f_t r_bare();       return F_A; endfunction
   function f_t r_tern(bit c);  return c ? F_A : F_B; endfunction
   function f_t r_cast();       return f_t'(F_B); endfunction
   function int r_castint();    return int'(F_C); endfunction
   function f_t r_rhs();        f_t v; v = F_C; return v; endfunction
   function int r_cmp();        return F_A == F_B; endfunction
   function f_t r_calla();      return r_id(F_B); endfunction
   function f_t r_id(f_t q);    return q; endfunction
   function int r_case(f_t q);  case (q) F_A: return 1; F_B: return 2; default: return 3; endcase endfunction
   function int r_init();       int v = F_C; return v; endfunction
   function int r_concat();     return {F_A, F_B}; endfunction
   function g_t r_based();      return G_A; endfunction
   function g_t r_based2();     return G_B; endfunction
   localparam int LP = F_C;

   class E;
      f_t p = F_B;                 // property initializer
      extern function f_t m_bare();
      extern function f_t m_tern(bit c);
      extern function f_t m_cast();
      extern function g_t m_based();
   endclass
   function f_t E::m_bare();      return F_C; endfunction
   function f_t E::m_tern(bit c); return c ? F_A : F_C; endfunction
   function f_t E::m_cast();      return f_t'(F_A); endfunction
   function g_t E::m_based();     return G_B; endfunction
endpackage

module v3top;
   v3p::E e;
   v3p::f_t a;
   v3p::g_t g;
   int i;
   initial begin
      a = v3p::r_bare(); a = v3p::r_tern(1); a = v3p::r_cast();
      i = v3p::r_castint(); a = v3p::r_rhs(); i = v3p::r_cmp();
      a = v3p::r_calla(); i = v3p::r_case(v3p::F_A); i = v3p::r_init();
      i = v3p::r_concat(); g = v3p::r_based(); g = v3p::r_based2();
      i = v3p::LP;
      e = new(); a = e.m_bare(); a = e.m_tern(0); a = e.m_cast(); g = e.m_based();
   end
endmodule
