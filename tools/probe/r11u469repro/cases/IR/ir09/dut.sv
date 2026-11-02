// § importCopyTsInstByRole469
// a signed typedef parameter with a negative default, read in an importer function
package a;
  typedef logic signed [7:0] t;
  parameter t PA = -1;
endpackage
package b;
  import a::*;
  function automatic int f(); return PA; endfunction
endpackage
module top;
  import b::*;
  int x;
  initial x = f();
endmodule
