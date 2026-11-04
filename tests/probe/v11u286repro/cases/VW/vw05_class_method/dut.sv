// § withCallParenSyntax286
class C;
  int q[$];
  function int f();
    return 1 + (q.sum() with (int'(item)));
  endfunction
endclass
module top;
  C c;
  initial begin c = new; void'(c.f()); end
endmodule
