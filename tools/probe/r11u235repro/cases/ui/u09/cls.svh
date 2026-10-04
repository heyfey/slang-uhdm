package p;
typedef struct packed { logic [3:0] a; logic b; } pk_t;
endpackage
import p::*;
class env;
  pk_t m;
endclass
