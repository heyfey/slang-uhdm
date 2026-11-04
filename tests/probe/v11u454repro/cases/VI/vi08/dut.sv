// § ifcTaskFixupWalksAllStmts454
interface ifc(input logic a);
  wire w;
  int late;
  assign w = a;
  function automatic int f(int k);
    if (k > late && w) return late;
    return k;
  endfunction
endinterface
module top(input logic a);
  ifc i(a);
  int r;
  initial r = i.f(2);
endmodule
