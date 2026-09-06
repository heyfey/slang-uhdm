// r10uvm169 arm B — THE RETURN FORMS AND THE WINDOW, inside a package that is
// WILDCARD-IMPORTED.  MEASUREMENT ONLY.
//
// Surelog's `paRETURN` arm is the only statement arm that threads the package
// compile's `Reduce::Yes` into `compileExpression` (CompileStmt.cpp:834-843),
// so a return nested in an `if`, an explicit `begin/end` or a `for` keeps the
// reference in the HOME's ELAB listing — and therefore in the CLONE, which is
// a copy of it.  A multi-statement body's SYNTHETIC begin is not such a
// nesting.  The non-bare forms (concatenation, arithmetic, conditional) are
// § negLitPkgRetFoldNested30's territory: golden reduces the WHOLE expression
// or keeps it, and this pass must not change either.
package p169hb;
  parameter int    kb169 = 5;
  parameter string sb169 = "bee";

  function int    f_bare169();  return kb169;              endfunction
  function int    f_arith169(); return kb169 + 1;          endfunction
  function int    f_cond169();  return kb169 ? 2 : 3;      endfunction
  function string f_cat169();   return {sb169, sb169};     endfunction
  function int    f_lit169();   return 42;                 endfunction
  function int    f_neg169();   return -3;                 endfunction
  function int    f_if169();    if (kb169 > 0) return kb169; else return 0; endfunction
  function int    f_beg169();   begin return kb169; end    endfunction
  function int    f_for169();   for (int i = 0; i < 1; i++) return kb169; endfunction
  function int    f_two169();   int t169; t169 = 1; return kb169; endfunction
  function int    f_arg169();   return $clog2(kb169);      endfunction
endpackage

package p169ib;
  import p169hb::*;
  parameter int ownb169 = 1;
  function int f_ownb169(); return ownb169; endfunction
endpackage

module g169_b_forms;
  import p169hb::*;
  import p169ib::*;
  int    b_i;
  string b_s;
  initial begin
    b_i = f_bare169() + f_arith169() + f_cond169() + f_lit169() + f_neg169() +
          f_if169() + f_beg169() + f_for169() + f_two169() + f_arg169() +
          f_ownb169();
    b_s = f_cat169();
  end
endmodule
