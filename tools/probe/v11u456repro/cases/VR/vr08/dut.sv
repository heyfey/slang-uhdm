// § ifcTransTdWriterRank456
package u;
  typedef enum {A, B} e_t;
endpackage
package mid;
  import u::*;
  int k;
endpackage
import mid::*;
interface zif;
  logic s;
endinterface
module hv;
  import mid::*;
  int e;
endmodule
module top;
  zif i();
  hv h();
endmodule
