// § importCopyTsInstByRole469
// the parameter's typedef has an unpacked-free 2-state packed array of a typedef
package a;
  typedef bit [1:0] p_t;
  typedef p_t [3:0] q_t;
  parameter q_t PQ = 8'ha5;
endpackage
package b;
  import a::*;
endpackage
module top;
  logic w;
endmodule
