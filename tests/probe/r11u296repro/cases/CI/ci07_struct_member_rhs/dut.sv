// § pkgFnCloneIdxNamesByChain296
package h;
  class c;
    int m;
    function int rub(input int x); return x + m; endfunction
  endclass
  typedef struct packed { logic [7:0] fld; } s_t;
  int pv;
  function automatic logic [7:0] f(input int a);
    s_t arr[4];
    int k;
    k = a;
    arr[0] = '0;
    f = arr[k].fld;
  endfunction
endpackage
package j;
  import h::*;
  function automatic int warp(input int z);
    return int'(f(z));
  endfunction
endpackage
module dut(output int o);
  import j::*;
  initial o = warp(1);
endmodule
