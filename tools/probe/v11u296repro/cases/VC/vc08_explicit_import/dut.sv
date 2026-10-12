// § pkgFnCloneIdxNamesByChain296
package h;
  class c;
    int m;
    int arr[4];
    function int rub(input int x); return x + m; endfunction
  endclass
  parameter int HP = 1;
  int pv;
  function automatic int f(input int a);
    c fl[4];
    int k;
    k = a;
    fl[0] = new();
    return fl[k].rub(k);
  endfunction
endpackage
package j;
  import h::f;
  import h::c;
  function automatic int warp(input int z);
    return f(z);
  endfunction
endpackage
module dut(output int o);
  initial o = j::warp(1);
endmodule
