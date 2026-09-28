// § namedUnlinkedWrittenOrder207 § namedOrderLinkedDeclines207v (an interface class's pure virtual function: called in-body by the implementing class, and through an interface-class handle)
package p;
  interface class IC;
    pure virtual function int f(int a, int b, int c);
  endclass
  class D implements IC;
    virtual function int f(int a, int b, int c);
      return a - b - c;
    endfunction
    function int g(int x);
      return f(.c(x), .a(1), .b(2));
    endfunction
  endclass
  class U;
    IC ic;
    function int h(int x);
      return ic.f(.b(x), .c(1), .a(3));
    endfunction
  endclass
endpackage
module top; endmodule
