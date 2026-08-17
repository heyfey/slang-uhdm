// MISC fences: named args, explicit pkg:: qualification, $unit-scope callee,
// deep nesting, a callee that FOLDS, a same-package callee used twice.
import "DPI-C" context function int dpi_unit(input int a);
function int unit_fn (int a); return dpi_unit(a); endfunction
package mp7;
  import "DPI-C" context function int dpi7(input int a, input int b);
  function int f2 (int a, int b); return dpi7(a, b); endfunction
  function int foldable (int a);  return a + 1; endfunction
  function int n_named (int a);   return f2(.a(a), .b(1)); endfunction
  function int n_pos (int a);     return f2(a, 1); endfunction
  function int n_fold (int a);    return foldable(a); endfunction
  function int n_deep (int a);    return f2(f2(a, 1), 2); endfunction
  function int n_twice (int a);   return f2(a, a); endfunction
endpackage
package qp7;
  import "DPI-C" context function int dpi7q(input int a);
  function int qf (int a); return dpi7q(a); endfunction
endpackage
package rp7;
  function int r_qual (int a);  return qp7::qf(a); endfunction
endpackage
module m7;
  int r[8];
  initial begin
    r[3]=mp7::n_fold(1);  r[4]=mp7::n_deep(1); r[5]=mp7::n_twice(1);
    r[6]=rp7::r_qual(1);
  end
endmodule
