// § importNetTsDimEnd275 — a multi-line declaration
package p;
  logic [1:0]
        [7:0] v
        [0:1];
endpackage
module dut (output logic [15:0] o);
  import p::*;
  assign o = v[0];
endmodule
