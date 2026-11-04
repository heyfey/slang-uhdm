// § namedUnlinkedWrittenOrder207 § namedOrderLinkedDeclines207v (an in-body caller of a same-class function declared LATER in the body, no package function of that name)
package p;
  class F;
    function int g(int x);
      return later(.c(x), .a(1));
    endfunction
    function int h(int x);
      return later(.b(x), .c(2), .a(0));
    endfunction
    function int later(int a, int b = 1, int c = 2);
      return a + b + c;
    endfunction
  endclass
endpackage
module top; endmodule
