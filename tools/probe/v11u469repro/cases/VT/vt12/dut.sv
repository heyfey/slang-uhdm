// § importCopyTsInstByRole469
// the importer is itself imported by an interface and a class reads the value (both importers)
package a;
  typedef logic [3:0] t;
  parameter t PA = 4'd5;
endpackage
package b;
  import a::*;
  class K; t m = PA; endclass
endpackage
package c;
  import b::*;
  import a::*;
endpackage
interface ifc;
  import c::*;
  logic [3:0] s;
endinterface
module top;
  ifc i();
endmodule
