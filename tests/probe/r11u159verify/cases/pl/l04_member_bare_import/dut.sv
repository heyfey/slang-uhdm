// § pkgLeafPatLocByWriting152
package pk;
  typedef struct packed { logic a; logic b; } s_t;
endpackage
module top(output logic [3:0] o);
  import pk::*;
  typedef struct packed { s_t [1:0] m; } w_t;
  w_t v;
  assign v = '1;
  assign o = v;
endmodule
