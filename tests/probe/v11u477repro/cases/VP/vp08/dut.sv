// § parenCallWrittenArgs477
package p;
  function automatic int f(int a, int b = 4); return a - b; endfunction
  function automatic int g(int a); return (f(a)); endfunction
endpackage
module top(output int z);
  initial z = p::g(9);
endmodule
