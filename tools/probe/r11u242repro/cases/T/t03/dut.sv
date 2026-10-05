// § impCondFlipTakenLeaf242
// Arithmetic leaves: the taken branch is LB - 1 (left operand anchor), LB + 1, (LB) * 2.
package fp;
  parameter int BusWidth = 32;
  parameter int DataWidth = 64;
  parameter int WidthMultiple = DataWidth / BusWidth;
  parameter int LsbAddrBit = $clog2(WidthMultiple);
  parameter int A = WidthMultiple == 1 ? 1 : LsbAddrBit - 1;
  parameter int B = WidthMultiple == 1 ? 1 : LsbAddrBit + 1;
  parameter int C = WidthMultiple == 1 ? 1 : (LsbAddrBit) * 2;
endpackage
module top import fp::*; #(parameter int P = 3) (output logic [A+B+C:0] o);
  assign o = '0;
endmodule
