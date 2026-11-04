// § ifcTransTdWriterRank456
package u;
  typedef enum {A, B} e_t;
endpackage
package mid;
  import u::*;
  typedef enum {C1, C2} h_t;
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
  zif i();
  hv h();
endmodule
