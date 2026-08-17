// ONE cell: a callee whose body FOLDS (R4).  Golden's ELABORATED listing
// replaces the whole call with a constant; we keep the call.
package fp9;
  function int foldable (int a); return a + 1; endfunction
  function int f_call (int a);   return foldable(a); endfunction
endpackage
module m9;
  int r;
  initial r = fp9::f_call(1);
endmodule
