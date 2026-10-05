// § impCondFlipTakenLeaf242
// Earlgrey's flash_phy_pkg WordSelW shape: the condition false, the taken branch a parameter
// reference, an importer with a parameter port list; read in a part-select width.
package fp;
  parameter int BusWidth = 32;
  parameter int DataWidth = 64;
  parameter int WidthMultiple = DataWidth / BusWidth;
  parameter int LsbAddrBit = $clog2(WidthMultiple);
  parameter int WordSelW = WidthMultiple == 1 ? 1 : LsbAddrBit;
endpackage
module top import fp::*; #(parameter bit S = 1) (input logic [7:0] addr_i, output logic [WordSelW-1:0] o);
  assign o = addr_i[0 +: WordSelW];
endmodule
