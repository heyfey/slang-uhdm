// § rawEndLineModel295
package pk;
  string sv = "a\\b` c"; int vi = 2;
endpackage
module dut (output int o);
  import pk::*;
  string ss = "a\\b` c"; int ni = 3;
  assign o = vi + ni;
endmodule
