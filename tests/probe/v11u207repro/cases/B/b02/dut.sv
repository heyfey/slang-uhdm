// § namedUnlinkedWrittenOrder207: an inherited task and function called with mixed positional and named arguments, an output formal named, and a call in a fork
package p;
class A;
  task t(input int a, input int b = 5, output int c, input int d = 7);
    c = a + b + d;
  endtask
  function int f(int a, int b = 1, int c = 2);
    return a + b + c;
  endfunction
endclass
class B extends A;
  int r;
  task run();
    int y;
    t(1, .c(y), .d(9));
    t(.d(8), .a(2), .c(y));
    fork
      r = f(.c(4), .a(r));
    join
    r = f(r, .c(3));
    r = f(.b(2), .a(1));
  endtask
endclass
endpackage
module top; endmodule
