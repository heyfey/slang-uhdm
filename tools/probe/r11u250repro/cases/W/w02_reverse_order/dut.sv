// § pcwRefLastWriter250
package z_common;
  localparam addr_w = 12;
  localparam base_a = (addr_w)'('h100);
endpackage
package a_user;
  import z_common::*;
  localparam y = 1;
endpackage
module top import a_user::*; import z_common::*; (output logic [31:0] o);
  assign o = base_a + y;
endmodule
