// § shallowCopyLhsUnbound413
class C;
  int a;
endclass
class D;
  C p, q;
  function void f();
    p = new;
    q = new p;
  endfunction
endclass
module top;
  D d;
  initial begin d = new; d.f(); end
endmodule
