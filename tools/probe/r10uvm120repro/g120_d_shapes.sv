// r10uvm120 arm d: the LOOKUP face — chained parameters, an operation-valued
// parameter, an enum constant, a package variable, and the two SHADOW shapes
// (a function local and a formal argument that carry a package parameter's
// name).
package p120d;
  parameter int A = 3;
  parameter int B = A + 1;
  parameter int C = B;
  parameter string SA = "sa";
  typedef enum int { E_ZERO = 0, E_ONE = 1 } e_t;
  parameter e_t EP = E_ONE;
  int pkgvar = 7;

  function int f_a();       return A;          endfunction
  function int f_b();       return B;          endfunction
  function int f_c();       return C;          endfunction
  function int f_ep();      return EP;         endfunction
  function int f_enum();    return E_ONE;      endfunction
  function int f_var();     return pkgvar;     endfunction
  function int f_qual();    return p120d::A;   endfunction
  function string f_squal(); return p120d::SA; endfunction

  function int f_localsh(); int A; A = 9; return A;    endfunction
  function int f_argsh(int A);           return A;     endfunction
  function int f_locstr(); string SA; SA = "z"; return SA == "z"; endfunction
endpackage

module top120d;
  initial $display(p120d::f_a(), p120d::f_b(), p120d::f_localsh(),
                   p120d::f_argsh(1), p120d::f_var());
endmodule
