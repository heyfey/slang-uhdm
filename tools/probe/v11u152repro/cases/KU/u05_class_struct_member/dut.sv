// § pkgElemMemberPatNoLoc152
package fp;
  typedef struct packed { logic a; logic b; } cf_t;
endpackage
class K;
  typedef struct packed {
    fp::cf_t [1:0] at;
  } t_t;
  t_t v;
endclass
module top();
  K k = new;
endmodule
