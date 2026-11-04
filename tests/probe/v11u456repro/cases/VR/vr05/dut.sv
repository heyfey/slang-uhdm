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
  zif i1();
  zif i2();
  hv h();
  for (genvar g = 0; g < 2; g++) begin : gg
    zif ig();
  end
endmodule
