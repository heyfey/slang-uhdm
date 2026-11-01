// § ifcTransTdWriterRank456
package u;
  typedef enum {A, B} e_t;
endpackage
package mid;
  import u::*;
  int k;
endpackage
interface zz1;
  import mid::*;
  logic s;
endinterface
interface zz2;
  import mid::*;
  logic t;
endinterface
module hv;
  import mid::*;
  int e;
endmodule
module top;
  zz1 i();
  zz2 j();
  hv h();
endmodule
