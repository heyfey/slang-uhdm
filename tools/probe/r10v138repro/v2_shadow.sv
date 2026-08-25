// V2 — SHADOWING and NAME-KEYED risk.  Surelog's getValue is NAME-keyed on
// the component; slang resolves the local.  Also: a formal argument and a
// class property carrying an enumerator's name.
package v2p;
   typedef enum { S_A, S_B } s_t;
   typedef enum { T_A = 3, T_B } t_t;

   // a LOCAL variable shadowing the enumerator name
   function int f_locsh();
      int S_A;
      S_A = 77;
      return S_A;
   endfunction
   // a FORMAL shadowing the enumerator name
   function int f_argsh(int S_B);
      return S_B;
   endfunction
   // control: no shadow
   function s_t f_plain();
      return S_B;
   endfunction
   // an enumerator whose initializer is an EXPRESSION over another member
   function t_t f_expr();
      return T_B;
   endfunction
   class D;
      int T_A;
      extern function int m_prop();
   endclass
   function int D::m_prop();
      return T_A;
   endfunction
endpackage

module v2top;
   v2p::D d;
   int x, y, z;
   v2p::s_t s;
   v2p::t_t t;
   initial begin
      x = v2p::f_locsh();
      y = v2p::f_argsh(4);
      s = v2p::f_plain();
      t = v2p::f_expr();
      d = new();
      z = d.m_prop();
   end
endmodule
