// § importCopyTsInstByRole469
// an interface and a program importing the home beside an importing package
package a;
  typedef logic [3:0] t;
  parameter t PA = 1;
endpackage
package b;
  import a::*;
endpackage
interface ifc;
  import a::*;
  t s = PA;
endinterface
program prg;
  import a::*;
  t v;
endprogram
module top;
  ifc i();
endmodule
