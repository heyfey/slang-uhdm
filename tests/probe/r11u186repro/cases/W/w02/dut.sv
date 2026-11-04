// § ifaceTwoPkgTdNameOrder186 (struct and enum typedefs, packages imported in reverse name order)
package pz;
  typedef struct packed { logic a; } req_t;
  typedef enum logic { OFF, ON } mode_t;
endpackage
package pa;
  typedef struct packed { logic [7:0] v; } data_t;
  typedef struct packed { logic b; } rsp_t;
endpackage
interface mem_if;
  import pz::*;
  import pa::*;
  req_t q;
  rsp_t r;
  data_t d;
  mode_t m;
endinterface
module top;
  mem_if i();
endmodule
