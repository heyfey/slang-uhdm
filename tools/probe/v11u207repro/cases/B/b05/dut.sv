// § namedUnlinkedWrittenOrder207: a derived class calling a base method through super with named arguments, and a class nested in a module calling an extern method before its body
class A;
  function int f(int a, int b = 1, int c = 2); return a + b + c; endfunction
endclass
class B extends A;
  function int f(int a, int b = 1, int c = 2);
    return super.f(.c(c), .a(a)) + f2(.z(3), .x(a));
  endfunction
  extern function int f2(int x, int y = 0, int z = 1);
endclass
function int B::f2(int x, int y = 0, int z = 1); return x + y + z; endfunction
module top(output int o);
  class K;
    extern function int k(int a, int b = 2, int c = 3);
    function int use1(); return k(.c(9), .a(1)); endfunction
  endclass
  function int K::k(int a, int b = 2, int c = 3); return a + b + c; endfunction
  initial begin
    K kk = new;
    B bb = new;
    o = kk.use1() + bb.f(1);
  end
endmodule
