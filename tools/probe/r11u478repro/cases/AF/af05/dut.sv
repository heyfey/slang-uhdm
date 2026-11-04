// § aliasFormalCopyPerClone478
package h;
  typedef enum {A, B} mode_e;
  typedef mode_e M_T;
  task automatic t1(input M_T v, output int o);
    o = int'(v);
  endtask
endpackage
package a;
  import h::*;
  class X; task g(); int o; t1(A, o); endtask endclass
endpackage
package b;
  import h::*;
  class Y; task g(); int o; t1(B, o); endtask endclass
endpackage
package c;
  import h::*;
  class W; task g(); int o; t1(A, o); endtask endclass
endpackage
module top;
  import a::*;
  import b::*;
  import c::*;
  X x; Y y; W w;
endmodule
