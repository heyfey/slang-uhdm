// § namedOrderLinkedDeclines207v (refines § namedUnlinkedWrittenOrder207): in-body named calls to extern tasks whose prototype sits above the caller (golden binds the prototype: formal order) and below it (no link: written order), and to a pure virtual task declared above
package p;
virtual class F;
  extern task ta(input int a, input int b = 3, output int c);
  pure virtual task tv(input int a, input int b, output int c);
  task k1(int x);
    int y;
    ta(.c(y), .b(x), .a(1));
    tb(.c(y), .b(x), .a(2));
    tv(.c(y), .a(x), .b(4));
  endtask
  extern task tb(input int a, input int b = 3, output int c);
endclass
task F::ta(input int a, input int b = 3, output int c); c = a + b; endtask
task F::tb(input int a, input int b = 3, output int c); c = a - b; endtask
endpackage
module top; endmodule
