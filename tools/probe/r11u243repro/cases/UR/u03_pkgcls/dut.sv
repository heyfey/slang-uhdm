// § clsImpUnsizedBasedRhsCopy243
// a class in a package importing another package's unsized based parameter
package q;
  parameter R = 'hf000000;
  parameter W = 16;
endpackage
package p;
  import q::*;
  class c;
    int v;
  endclass
endpackage
module top;
  import p::*;
  c h;
endmodule
