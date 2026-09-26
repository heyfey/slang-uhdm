// § refFullNameThroughNamedExpr175
class B; function int h(int x); return x; endfunction endclass
interface ifc; function automatic int g(int x); return x; endfunction endinterface
module top;
  ifc i();
  B b;
  int r;
  function automatic int mf(int k); return i.g(k) + b.h(k+1); endfunction
  task automatic mt(int k); r = b.h(k); endtask
  initial begin b = new; r = mf(1); mt(2); r = b.h(r); r = i.g(r); end
endmodule
