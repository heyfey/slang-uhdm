// § impCondFlipTakenLeaf242
// Control: the same package imported by a module WITHOUT a parameter port list (pristine's
// § impCondBranchFold) and by one with it, side by side; an instance of each.
package fp;
  parameter int BusWidth = 32;
  parameter int DataWidth = 64;
  parameter int WidthMultiple = DataWidth / BusWidth;
  parameter int LsbAddrBit = $clog2(WidthMultiple);
  parameter int WordSelW = WidthMultiple == 1 ? 1 : LsbAddrBit;
endpackage
module a import fp::*; (output logic [WordSelW-1:0] o);
  assign o = '0;
endmodule
module b import fp::*; #(parameter bit S = 1) (output logic [WordSelW-1:0] o);
  assign o = '1;
endmodule
module top (output logic [1:0] o1, output logic [1:0] o2);
  a ua (.o(o1));
  b ub (.o(o2));
endmodule
