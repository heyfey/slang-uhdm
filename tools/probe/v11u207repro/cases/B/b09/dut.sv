// § namedOrderLinkedDeclines207v (refines § namedUnlinkedWrittenOrder207): an in-body method calling an extern sibling whose prototype sits above it (golden binds the prototype): complete lists written out of formal order, and a list skipping a defaulted formal
package p;
class F;
  extern function int mt(int a, int b = 1, int c = 2);
  extern task tt(input int a, input int b = 3, output int c);
  task tk(int x);
    int y;
    tt(.c(y), .b(x), .a(1));
  endtask
  function int g(int x);
    return mt(.c(x), .b(1), .a(0)) + mt(.b(x), .c(2), .a(3));
  endfunction
  function int h(int x); return mt(.c(x), .a(0)); endfunction
endclass
function int F::mt(int a, int b = 1, int c = 2); return a + b + c; endfunction
task F::tt(input int a, input int b = 3, output int c); c = a + b; endtask
endpackage
module top; endmodule
