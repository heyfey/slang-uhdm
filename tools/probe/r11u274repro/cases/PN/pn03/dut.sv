// § pkgNetTsDimEnd274
package pc;
  typedef logic [7:0] b_t;
  wire  b_t a_td [0:1];
  wire  b_t [1:0] a_tdp;
  wire signed [7:0] a_sg [0:1];
  tri [7:0] a_tri [2];
endpackage
module dut (output logic [31:0] o);
  import pc::*;
  assign o = a_td[0] ^ a_tdp ^ a_sg[1];
endmodule
