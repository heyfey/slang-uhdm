// § unitClsAggTdLastWriter235
package p;
typedef bit [63:0] addr_t;
typedef enum {RD, WR} kind_e;
typedef struct {
  kind_e kind;
  addr_t addr;
  int n_bits;
} bus_op;
endpackage
import p::*;
class env;
  int x;
endclass
module top;
endmodule
