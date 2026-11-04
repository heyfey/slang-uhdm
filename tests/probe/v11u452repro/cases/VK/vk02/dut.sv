// § clsImpRepTsClassKey452
package u;
  class Cb #(type T = int);
    int k;
  endclass
endpackage
package a;
  import u::*;
  class A;
    typedef Cb #(A) cb_type;
  endclass
endpackage
package b;
  import u::*;
  import a::*;
  class B;
    typedef Cb #(B) cb_type;
    int z;
  endclass
endpackage
module top;
  import b::*;
endmodule
