// § importNetTsDimEnd275 — a reg 2-D packed variable
package p;
  reg [1:0][3:0] v;
endpackage
module dut (output logic [7:0] o);
  import p::*;
  assign o = v;
endmodule
