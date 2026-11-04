// § pkgArrTdBindCopies250
// size 1, a reversed range, signed and integer-keyword elements, multiple declarators and an initializer
package p;
  typedef bit one_t [1];
  typedef logic signed [3:0] sv_t [2:0];
  typedef integer in_t [0:1];
  typedef int unsigned iu_t [3];
  typedef time t_t [2];
endpackage
module top(input logic [3:0] i, output logic [3:0] o);
  import p::*;
  one_t a;
  sv_t b, c;
  in_t d = '{default: 0};
  iu_t e;
  t_t f;
  always_comb begin
    a[0] = i[0];
    b[2] = i;
    c = b;
    e[1] = d[1];
    f[0] = 0;
    o = c[2] + 4'(e[1]);
  end
endmodule
