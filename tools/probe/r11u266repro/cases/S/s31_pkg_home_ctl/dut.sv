// § sgnLitElabFreshIntTs266
package pk;
  parameter int P = 12'shFFF;
endpackage
module dut import pk::*; (output logic [63:0] o);
  assign o = P;
endmodule
