// § typedefParentLastWriter134
package p;
  typedef struct packed { logic [3:0] x; logic y; } t;
endpackage
program prg;
  import p::*;
  t q;
  initial q = '0;
endprogram
module top(output logic [3:0] o);
  import p::*;
  t r;
  always_comb r = '{x: 4'h2, y: 1'b1};
  assign o = r.x;
endmodule
