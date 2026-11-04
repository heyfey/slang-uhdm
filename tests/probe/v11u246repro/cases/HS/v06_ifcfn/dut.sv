// § hpFnStaticTrailScopeJoin246
interface ifc;
  function int cnt();
    static int n;
    n++;
    return n;
  endfunction
  function int peek();
    return cnt.n;
  endfunction
endinterface
module top;
  ifc i0();
  int r;
  initial r = i0.peek();
endmodule
