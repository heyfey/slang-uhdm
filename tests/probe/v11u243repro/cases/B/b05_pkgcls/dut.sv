// § clsImpUnsizedBasedRhsCopy243
// a class in a package importing another package with unsized literals, and a derived class
package q;
  parameter A = 'hf0;
  parameter B = '1;
  parameter int C = 'h3;
endpackage
package p;
  import q::*;
  class b;
    int v;
  endclass
  class d extends b;
    int w;
  endclass
endpackage
module top;
  import p::*;
  d o;
endmodule
