// § pcwRefLastWriter250
package common_pkg;
  localparam addr_w = 8;
  localparam base_a = (addr_w)'('h10);
endpackage
package be_pkg;
  import common_pkg::*;
  localparam k = 2;
endpackage
module sub import common_pkg::*; (output logic [31:0] o);
  assign o = base_a;
endmodule
module top import be_pkg::*; import common_pkg::*; (output logic [31:0] o, output logic [31:0] p);
  sub u(.o(o));
  assign p = base_a + k;
endmodule
