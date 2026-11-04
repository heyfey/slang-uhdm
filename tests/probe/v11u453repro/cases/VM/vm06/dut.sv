// § modCopyImportsFirst453
package a;
  parameter int PA = 1;
endpackage
package b;
  int vb;
  import a::*;
endpackage
module top;
  import b::*;
endmodule
