// § pkgQualCaReadValueForm475
package a;
  parameter logic [7:0] PH = 8'h2a;
  parameter logic [3:0] PB = 4'b1010;
  parameter logic [5:0] PO = 6'o41;
  parameter logic [5:0] PD = 6'd33;
  parameter int PI = 3;
  parameter PU = 5;
  parameter PDU = 6'd7;
endpackage
module top(output logic [7:0] y1, output logic [3:0] y2, output logic [5:0] y3,
           output logic [5:0] y4, output logic [31:0] y5, output logic [31:0] y6, output logic [5:0] y7);
  assign y1 = a::PH;
  assign y2 = a::PB;
  assign y3 = a::PO;
  assign y4 = a::PD;
  assign y5 = a::PI;
  assign y6 = a::PU;
  assign y7 = a::PDU;
endmodule
