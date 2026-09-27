// § memberBareTdAliasNamedByUse183 (a nested struct member, two importers, an interface importer)
package p;
  typedef bit [3:0] be_t;
  typedef logic lg_t;
  typedef struct packed { be_t b; lg_t l; } in_t;
  typedef struct packed { in_t i; be_t c; } op_t;
endpackage
interface bus_if;
  import p::*;
  op_t o;
endinterface
module m;
  import p::*;
  op_t v;
endmodule
module top;
  bus_if b();
  m u();
endmodule
