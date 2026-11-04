// § aliasFormalCopyPerClone478 (task output and inout formals)
package h;
  typedef enum {A, B} mode_e;
  typedef mode_e M_T;
  task automatic t(output M_T o, inout M_T io);
    o = A; io = B;
  endtask
endpackage
package i0;
  import h::*;
  class X0; task g(); M_T a, b; t(a, b); endtask endclass
endpackage
package i1;
  import h::*;
  class X1; task g(); M_T a, b; t(a, b); endtask endclass
endpackage
module top;
  import i0::*; import i1::*;
  X0 x0; X1 x1;
endmodule
