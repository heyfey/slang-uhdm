// § importCopyTsInstByRole469
// a home parameter whose default reads a function of the home
package a;
  typedef logic [7:0] t;
  function automatic t f(input int x); return t'(x * 3); endfunction
  parameter t PA = f(5);
endpackage
package b;
  import a::*;
endpackage
module top;
  logic w;
endmodule
