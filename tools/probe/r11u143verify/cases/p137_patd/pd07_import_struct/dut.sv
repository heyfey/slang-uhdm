// § packedArrTdElemRefName137
// case pd07: a package packed-array struct typedef used through a wildcard import
package sp7;
  typedef struct packed { logic x; logic y; } s_t;
  typedef s_t [2:0] sa_t;
endpackage
module top(output logic [5:0] o);
  import sp7::*;
  sa_t v;
  assign v = 6'h2A;
  assign o = v;
endmodule
