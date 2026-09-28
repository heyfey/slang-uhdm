// § namedUnlinkedWrittenOrder207: a parameterized class (a specialization) whose extern method is called with reordered named arguments before its body, and an inherited call in a derived specialization
package p;
class B #(int W = 4);
  extern function int mt(int a, int b = W, int c = 2);
  extern function void g(int x);
endclass
function void B::g(int x);
  int r;
  r = mt(.c(x), .a(1));
endfunction
function int B::mt(int a, int b = W, int c = 2);
  return a + b + c;
endfunction
class D extends B #(8);
  function void h(int y);
    int r;
    r = mt(.b(y), .a(2));
  endfunction
endclass
endpackage
module top; p::D d; initial begin d = new; d.h(1); end endmodule
