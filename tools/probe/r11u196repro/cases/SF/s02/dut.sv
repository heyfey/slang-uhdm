// § tfFormalTdCloneFile196: a class method formal and a package task formal in an included header, typed by scalar typedefs declared in another header
package p;
`include "types.svh"
`include "fns.svh"
endpackage
module top;
  import p::*;
  it_t w;
endmodule
