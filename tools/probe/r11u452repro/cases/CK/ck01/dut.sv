// § clsImpRepTsClassKey452
package u;
  class E #(type T = int);
    T v;
  endclass
  class R;
    int r;
  endclass
endpackage
package a;
  import u::*;
  class S;
    typedef E#(S) cb_type;
    cb_type h;
  endclass
endpackage
package b;
  import u::*;
  import a::*;
  class Z;
    typedef int type_id;
    type_id k;
  endclass
endpackage
module top;
  import b::*;
endmodule
