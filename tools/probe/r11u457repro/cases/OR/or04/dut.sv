// § oobClsRetCallSharesCalleeRet457
module top;
  function int rep(int v);
    return v + 1;
  endfunction
  class C;
    extern function int f(int a);
  endclass
  function int C::f(int a);
    return rep(a);
  endfunction
  C c;
endmodule
