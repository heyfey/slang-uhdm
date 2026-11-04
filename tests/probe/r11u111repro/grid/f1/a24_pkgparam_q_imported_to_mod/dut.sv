package q;
  typedef logic [2:0] mask_t;
endpackage
package r;
  parameter q::mask_t RM = 3'b011;
endpackage
module dut (output logic [2:0] o);
  import r::*;
  assign o = RM;
endmodule
