// § clsPropLawSAliasName243
// classes declared in an interface and in a program with package-typedef properties
package p;
  typedef int i_t;
endpackage
interface ifc;
  import p::*;
  class ic;
    i_t m;
  endclass
endinterface
program prg;
  import p::*;
  class pc;
    i_t m;
  endclass
endprogram
module top;
  ifc i();
  prg g();
endmodule
