// § namedOrderLinkedDeclines207v (refines § namedUnlinkedWrittenOrder207): an in-body method calling a same-class method declared below it that golden binds to the package free function of that name, with a reordered named list
package p;
function automatic int late(int a, int b = 1, int c = 2); return a - b - c; endfunction
class F;
  function int g(int x); return late(.c(x), .b(2), .a(1)); endfunction
  function int late(int a, int b = 1, int c = 2); return a + b + c; endfunction
endclass
endpackage
module top; endmodule
