// § pkgNetTsDimEnd274
package pk;
  tri [3:0] t [4];
  wand w [0:1];
  wor [1:0][1:0] r;
  uwire [1:0][2:0] u;
  tri1 [3:0] s1 [2];
endpackage
module dut(output logic [3:0] o); import pk::*; assign o = t[0] ^ r ^ {3'b0, w[0]}; endmodule
