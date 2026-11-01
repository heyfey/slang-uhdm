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
program pz;
  import mid::*;
endprogram
module top;
  zif i();
  pz p();
endmodule
