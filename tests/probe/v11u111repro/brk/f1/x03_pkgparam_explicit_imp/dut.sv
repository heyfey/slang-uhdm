package q;
  typedef logic [2:0] mask_t;
endpackage
package r;
  parameter q::mask_t RM = 3'b011;
  parameter q::mask_t RN = 3'b100;
endpackage
module dut (output logic [2:0] o, output logic [2:0] p);
  import r::RM;
  assign o = RM;
  assign p = r::RN;
endmodule
