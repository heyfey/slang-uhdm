// § refChainHexWrittenCase475
// a module-local chain and an untyped unsized hex origin
module top(output logic [7:0] y, output logic [31:0] z);
  parameter logic [7:0] HA = 8'hff;
  parameter logic [7:0] HB = HA;
  parameter HC = 'hab;
  parameter HD = HC;
  assign y = HB;
  assign z = HD;
endmodule
