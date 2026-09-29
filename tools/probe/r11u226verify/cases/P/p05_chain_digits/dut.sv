// § ppDotNameAfterArgToken219 § ppIdentEndInRebuiltText219 — method names with digits and underscores (get_v2_x9) on a forwarded actual, one and two levels
`define ONE(A) A.get_v2_x9()
`define TWO(A) \
  begin \
    int t; \
    t = `ONE(A) + A.m_1(); \
  end
package p;
class k_c;
  function int get_v2_x9(); return 2; endfunction
  function int m_1(); return 1; endfunction
endclass
class user_c;
  k_c kk;
  function int run();
    `TWO(kk)
    return `ONE(kk);
  endfunction
endclass
endpackage
module top;
  import p::*;
endmodule
