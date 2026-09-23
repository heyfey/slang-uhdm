package q;
  localparam int NF = 3;
  typedef logic [NF-1:0] mask_t;
endpackage
package r;
  parameter q::mask_t RM = 3'b011;
endpackage
module a1 (output logic [2:0] o);
  import r::*;
  assign o = RM;
endmodule
module dut (output logic [2:0] o, output logic [2:0] p);
  import r::*;
  a1 u (.o(p));
  assign o = RM ^ 3'b1;
endmodule
