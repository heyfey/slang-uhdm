// § impCondFlipTakenLeaf242
// A nested ternary (the chain walked to its leaf) and a ternary whose taken branch is a
// system call.
package fp;
  parameter int BusWidth = 32;
  parameter int DataWidth = 64;
  parameter int WidthMultiple = DataWidth / BusWidth;
  parameter int LsbAddrBit = $clog2(WidthMultiple);
  parameter int A = WidthMultiple == 1 ? 1 : WidthMultiple == 2 ? LsbAddrBit : 3;
  parameter int B = WidthMultiple > 1 ? $clog2(DataWidth) : 0;
endpackage
module top import fp::*; #(parameter int P = 3) (output logic [A+B:0] o);
  assign o = '0;
endmodule
