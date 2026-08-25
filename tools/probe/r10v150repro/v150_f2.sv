// r10v150 fence 2 — a BARE root followed by an INDEX  `f().arr[1]`.
package fp2;
  class LL; int arr[4]; function int mm(int a); return a; endfunction endclass
  function LL mk(); LL l = new(); return l; endfunction
endpackage
module TF2;
  import fp2::*;
  function int h1(); return mk().arr[1]; endfunction
  int r; initial r = h1();
endmodule
