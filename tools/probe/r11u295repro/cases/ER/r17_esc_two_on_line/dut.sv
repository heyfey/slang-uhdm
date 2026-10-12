// § rawEndLineModel295
package pk;
  int \v.a = 1, \v.b = 2;
endpackage
module dut (output int o);
  import pk::*;
  assign o = \v.a + \v.b ;
endmodule
