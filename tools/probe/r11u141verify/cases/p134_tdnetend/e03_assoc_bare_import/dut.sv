// § defNetTypedefEndWrite134
// case e03: package union typedef referenced bare after an import, as an unpacked array net
package p;
  typedef union packed { logic [7:0] w; logic [3:0][1:0] q; } u_t;
endpackage
module top(output logic [7:0] o);
  import p::*;
  u_t f [3];
  assign f[1] = 8'h5A;
  assign o = f[1].w;
endmodule
