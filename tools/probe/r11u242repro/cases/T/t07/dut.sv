// § impCondFlipTakenLeaf242
// A localparam ternary of the module itself (not imported: no law) beside the imported one,
// and an interface importer with a parameter port list.
package fp;
  parameter int BusWidth = 32;
  parameter int DataWidth = 64;
  parameter int WidthMultiple = DataWidth / BusWidth;
  parameter int LsbAddrBit = $clog2(WidthMultiple);
  parameter int WordSelW = WidthMultiple == 1 ? 1 : LsbAddrBit;
endpackage
interface ifc import fp::*; #(parameter int W = 2);
  logic [WordSelW-1:0] v;
endinterface
module top import fp::*; #(parameter int P = 3) (output logic [1:0] o);
  localparam int L = P == 3 ? WordSelW : 5;
  ifc i0 ();
  assign o = L[1:0];
endmodule
