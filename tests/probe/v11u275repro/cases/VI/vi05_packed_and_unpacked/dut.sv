// § importNetTsDimEnd275 — packed 2-D and unpacked
package p;
  logic [1:0][3:0] v [0:2];
endpackage
module dut (output logic [7:0] o);
  import p::*;
  assign o = v[0];
endmodule
