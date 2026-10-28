// § clsImpRepTsClassKey452
package u;
  class Reg #(type T = int);
    int k;
  endclass
  class Base;
    int b;
  endclass
endpackage
package a;
  import u::*;
  class A extends Base;
    typedef Reg #(A) type_id;
  endclass
endpackage
package b;
  import u::*;
  import a::*;
  class B extends Base;
    typedef Reg #(B) type_id;
  endclass
endpackage
module top;
  import b::*;
endmodule
