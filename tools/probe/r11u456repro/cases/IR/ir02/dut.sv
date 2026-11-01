// § ifcTransTdWriterRank456
package u;
  typedef enum {A, B} e_t;
endpackage
package mid;
  import u::*;
  int k;
endpackage
interface aif;
  import mid::*;
  logic s;
endinterface
module zz;
  import mid::*;
endmodule
module top;
  aif i();
  zz h();
endmodule
