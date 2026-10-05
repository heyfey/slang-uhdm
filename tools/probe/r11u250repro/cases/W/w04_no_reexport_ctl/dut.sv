// § pcwRefLastWriter250 (control: no importing package)
package common_pkg;
  localparam addr_w = 16;
  localparam base_a = (addr_w)'('h1000);
endpackage
module top import common_pkg::*; (output logic [31:0] o);
  assign o = base_a;
endmodule
