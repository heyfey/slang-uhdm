// § ifcTransTdWriterRank456
package u;
  typedef enum {A, B} e_t;
  typedef enum logic [1:0] {X, Y, Z} f_t;
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
  zif i();
  hv h();
endmodule
