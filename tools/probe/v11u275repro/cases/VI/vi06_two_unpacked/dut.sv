// § importNetTsDimEnd275 — two unpacked dimensions
package p;
  logic [7:0] v [0:1][0:3];
endpackage
module dut (output logic [7:0] o);
  import p::*;
  assign o = v[1][2];
endmodule
