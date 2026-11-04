// § ifcTaskFixupWalksAllStmts454
interface ifc;
  int x;
  logic v;
  function automatic int f();
    int x;
    x = 3;
    return x;
  endfunction
  function automatic logic g();
    return v;
  endfunction
  function automatic void h();
    return;
  endfunction
endinterface
module top;
  ifc i();
  int r; logic s;
  initial begin r = i.f(); s = i.g(); i.h(); end
endmodule
