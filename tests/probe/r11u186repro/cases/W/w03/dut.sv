// § ifaceTwoPkgTdNameOrder186 (control: one package)
package pz;
  typedef struct packed { logic a; } z_t;
  typedef struct packed { logic b; } a_t;
endpackage
interface one_if;
  import pz::*;
  z_t q;
endinterface
module top;
  one_if i();
endmodule
