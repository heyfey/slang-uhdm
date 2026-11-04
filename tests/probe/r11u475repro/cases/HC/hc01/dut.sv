// § refChainHexWrittenCase475
// hex chains with lowercase, uppercase and mixed digits
package a;
  parameter logic [15:0] PL = 16'hbeef;
  parameter logic [15:0] PU = 16'hBEEF;
  parameter logic [15:0] PM = 16'hBeEf;
  parameter logic [15:0] QL = PL;
  parameter logic [15:0] QU = PU;
  parameter logic [15:0] QM = PM;
endpackage
module top(output logic [15:0] y, output logic [15:0] z, output logic [15:0] w);
  import a::*;
  assign y = QL;
  assign z = QU;
  assign w = QM;
endmodule
