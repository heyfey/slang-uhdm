// § typedefParentLastWriter134
// case a02: a package union typedef imported by a program and by two modules
package p;
  typedef union packed { logic [7:0] w; logic [3:0][1:0] q; } u_t;
endpackage
program prg;
  import p::*;
  u_t r;
endprogram
module sub(output logic [7:0] o);
  import p::*;
  u_t k;
  assign k = 8'h11;
  assign o = k.w;
endmodule
module top(output logic [7:0] o);
  import p::*;
  u_t m;
  sub s(.o(o));
  prg pg();
endmodule
