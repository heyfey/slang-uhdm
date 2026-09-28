// § namedUnlinkedWrittenOrder207 § namedOrderLinkedDeclines207v (a subclass calling the base's extern task whose prototype sits above; the base body compiled later)
package p;
  class A;
    extern task t(input int a, input int b = 3, output int c);
  endclass
  class B extends A;
    task run();
      int y;
      t(.c(y), .a(1));
      t(.b(2), .c(y), .a(4));
    endtask
  endclass
  task A::t(input int a, input int b = 3, output int c);
    c = a + b;
  endtask
endpackage
module top; endmodule
