// § importNetTsDimEnd275 — an explicit import
package p;
  logic [1:0][7:0] v;
  logic [7:0] w [0:1];
endpackage
module dut (output logic [15:0] o, output logic [7:0] q);
  import p::v;
  import p::w;
  assign o = v;
  assign q = w[0];
endmodule
