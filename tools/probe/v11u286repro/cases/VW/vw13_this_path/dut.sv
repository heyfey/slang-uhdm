// § withCallParenSyntax286
class C;
  int q[$];
  int r;
  function void f();
    r = 1 + (this.q.sum() with (item));
  endfunction
endclass
module top;
  C c;
  initial begin c = new; c.f(); end
endmodule
