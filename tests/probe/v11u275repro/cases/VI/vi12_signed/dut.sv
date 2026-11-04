// § importNetTsDimEnd275 — a signed 2-D packed variable
package p;
  logic signed [1:0][7:0] v;
endpackage
module dut (output logic [15:0] o);
  import p::*;
  assign o = v;
endmodule
