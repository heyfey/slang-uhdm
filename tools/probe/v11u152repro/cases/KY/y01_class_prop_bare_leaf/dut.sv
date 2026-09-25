// § pkgLeafPatLocByWriting152
package pk;
  typedef struct packed { logic a; logic b; } s_t;
endpackage
import pk::*;
class K;
  s_t [2:0] m;
endclass
module top (output int x);
  K k = new;
  assign x = 0;
endmodule
