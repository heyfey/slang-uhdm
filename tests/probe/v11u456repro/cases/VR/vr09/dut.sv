// § ifcTransTdWriterRank456
package u;
  typedef enum {A, B} e_t;
endpackage
package mid;
  import u::*;
  int k;
endpackage
interface zif;
  import mid::*;
  logic s;
endinterface
module hv;
  import mid::*;
  int e;
endmodule
module top;
  hv h();
endmodule
