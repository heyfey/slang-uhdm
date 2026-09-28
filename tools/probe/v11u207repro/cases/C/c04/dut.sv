// § namedSlotFillerRootFile207: an in-body class method calling a sibling method by name in an included class, and a package function calling another by name
package p;
`include "cls.svh"
  function automatic int pf(int a, int b = 4, int c = 5); return a + b + c; endfunction
  function automatic int pg(); return pf(.a(1)); endfunction
endpackage
module top(output int o);
  initial begin p::K k = new; o = k.g() + p::pg(); end
endmodule
