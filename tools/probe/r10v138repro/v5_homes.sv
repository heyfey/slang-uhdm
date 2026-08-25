// V5 — HOMES: package free fn / out-of-body method / in-body method / module
// function / $unit function / interface function / PARAMETERIZED class oob /
// nested class / anonymous enum / class-scope enum / function-local typedef.
typedef enum { U_A, U_B } u_t;
function u_t u_free();
   return U_B;                    // $unit home — must NOT fold
endfunction

package v5p;
   typedef enum { H_A, H_B, H_C } h_t;
   enum { AN_A, AN_B } an_var;                 // ANONYMOUS package enum

   function h_t free_ret();  return H_A; endfunction
   function int an_ret();    return AN_B; endfunction
   function h_t loc_ret();
      typedef enum { L_A, L_B } l_t;           // FUNCTION-LOCAL typedef
      l_t v;
      v = L_B;
      return H_B;
   endfunction
   function int loc_ret2();
      typedef enum { M_A, M_B } m_t;
      return M_B;                              // function-local -> no fold
   endfunction

   class CA;
      typedef enum { CE_A, CE_B } ce_t;        // CLASS-SCOPE enum
      extern function h_t oob_ret();
      extern function ce_t oob_cls();
      function h_t inb_ret(); return H_C; endfunction     // IN-BODY -> no fold
      function ce_t inb_cls(); return CE_B; endfunction
   endclass
   function h_t  CA::oob_ret(); return H_B; endfunction   // OOB -> fold
   function CA::ce_t CA::oob_cls(); return CE_A; endfunction // class enum -> no fold

   class PC #(int W = 4);
      extern function h_t pm();
   endclass
   function h_t PC::pm(); return H_C; endfunction         // parameterized OOB

endpackage

module v5mod;
   function v5p::h_t mf_ret();
      return v5p::H_A;            // module home — must NOT fold
   endfunction
   v5p::h_t r;
   initial r = mf_ret();
endmodule

interface v5if;
   function v5p::h_t if_ret();
      return v5p::H_B;            // interface home — must NOT fold
   endfunction
endinterface

module v5top;
   v5p::CA ca;
   v5p::PC #(8) pc;
   v5mod m1();
   v5if  i1();
   v5p::h_t a; u_t b; int i;
   initial begin
      a = v5p::free_ret(); i = v5p::an_ret(); a = v5p::loc_ret(); i = v5p::loc_ret2();
      b = u_free();
      ca = new(); a = ca.oob_ret(); i = ca.oob_cls(); a = ca.inb_ret(); i = ca.inb_cls();
      pc = new(); a = pc.pm();
      a = i1.if_ret();
   end
endmodule
