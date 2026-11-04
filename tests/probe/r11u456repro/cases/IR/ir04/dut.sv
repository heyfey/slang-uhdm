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
module bm;
  import u::*;
endmodule
module cm;
  import mid::*;
endmodule
module top;
  zif i();
  bm b();
  cm c();
endmodule
