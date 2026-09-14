// t2: t1's PACKAGE twin -- type parameters written in a package.
package pk;
  parameter  type PT1 = int;
  localparam type LT1 = int;
  parameter  int  PV1 = 1;
  localparam int  LV1 = 2;
endpackage
module dut(input logic i, output logic o);
  pk::PT1 a; pk::LT1 b;
  assign o = i ^ (|{a,b}) ^ pk::PV1[0] ^ pk::LV1[0];
endmodule
