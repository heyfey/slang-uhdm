// t8: a WILDCARD-IMPORTED package type parameter (the design-import copy path)
// in both written forms.
package pk;
  parameter  type PT = logic [3:0];
  localparam type LT = logic [7:0];
  parameter  int  PV = 1;
  localparam int  LV = 2;
endpackage
import pk::*;
module dut(output logic o);
  PT a; LT b;
  assign o = (|{a}) ^ (|{b}) ^ PV[0] ^ LV[0];
endmodule
