// § pcwRefLastWriter250
package common_pkg;
  localparam id_w = 4;
  localparam addr_w = 20;
  localparam base_a = (addr_w)'('h0_1000);
  localparam base_b = (id_w+addr_w)'('h010_0000);
endpackage
package be_pkg;
  import common_pkg::*;
  localparam x_w = 3;
endpackage
module top import common_pkg::*; import be_pkg::*; (output logic [31:0] o);
  assign o = base_a + x_w;
endmodule
