// § ifcTransTdWriterRank456
package u;
  typedef enum {A, B} e_t;
  typedef enum logic [2:0] {P, Q} g_t;
endpackage
package mid;
  import u::*;
  int k;
endpackage
interface zif;
  import mid::*;
  logic s;
endinterface
interface yif;
  import mid::*;
  logic s;
endinterface
module top;
  zif i();
  yif j();
endmodule
