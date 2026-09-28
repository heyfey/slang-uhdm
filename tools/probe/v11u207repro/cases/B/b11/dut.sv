// § namedOrderLinkedDeclines207v (refines § namedUnlinkedWrittenOrder207): a pure virtual prototype called in-body by name out of formal order from a derived class and from the declaring class
package p;
virtual class V;
  pure virtual function int pv(int a, int b, int c);
  function int use1(); return pv(.c(3), .a(1), .b(2)); endfunction
endclass
class D extends V;
  function int pv(int a, int b, int c); return a; endfunction
  function int use2(); return pv(.b(5), .c(6), .a(4)); endfunction
endclass
endpackage
module top; endmodule
