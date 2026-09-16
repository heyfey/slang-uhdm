// ROAD B, MODULE-BODY holder: the same three cells as a module localparam,
// reading a PACKAGE parameter and a MODULE parameter leaf.
package pk;
  parameter logic [1:0] C0 = 2'b00;
endpackage
module dut #(parameter logic [1:0] MP = 2'b01) (output logic o);
  localparam logic [15:0] R = { 3'b000, 11'b0, {pk::C0} };
  localparam logic [15:0] X = { 3'b000, 11'h?, {pk::C0} };
  localparam logic [15:0] XM = { 3'b000, 11'h?, {MP} };
  localparam logic [1:0]  S = pk::C0;
  assign o = ^{R[0], X[0], XM[0], S[0]};
endmodule
