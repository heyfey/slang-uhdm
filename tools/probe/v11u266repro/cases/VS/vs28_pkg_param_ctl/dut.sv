// § sgnLitElabFreshIntTs266
package p;
  parameter int P = 8'sh7F;
endpackage
module dut (output logic [31:0] o, output logic [31:0] q);
  import p::*;
  localparam int L = 8'sh11;
  assign o = P;
  assign q = L + p::P;
endmodule
