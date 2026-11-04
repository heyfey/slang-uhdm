// § hpFnStaticTrailScopeJoin246
package p;
  class c;
    extern function int cnt();
    extern function int peek();
  endclass
  function int c::cnt();
    static int n;
    n++;
    return n;
  endfunction
  function int c::peek();
    return cnt.n;
  endfunction
endpackage
module top;
endmodule
