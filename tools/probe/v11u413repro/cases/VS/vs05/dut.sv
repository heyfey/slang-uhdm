// § shallowCopyLhsUnbound413
class C;
  int a;
endclass
class H;
  C c1, c2;
  function void f();
    c1 = new;
    c2 = new c1;
  endfunction
endclass
module top;
  H h;
  initial begin h = new; h.f(); end
endmodule
