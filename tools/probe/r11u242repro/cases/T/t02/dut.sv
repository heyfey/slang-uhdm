// § impCondFlipTakenLeaf242
// The condition true (the left branch taken), a literal leaf and a parameter leaf.
package fp;
  parameter int BusWidth = 32;
  parameter int DataWidth = 64;
  parameter int WidthMultiple = DataWidth / BusWidth;
  parameter int LsbAddrBit = $clog2(WidthMultiple);
  parameter int A = WidthMultiple == 2 ? LsbAddrBit : 9;
  parameter int B = WidthMultiple == 1 ? 1 : 7;
endpackage
module top import fp::*; #(parameter int P = 3) (output logic [A+B-1:0] o);
  assign o = '0;
endmodule
