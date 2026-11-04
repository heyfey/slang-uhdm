// § impCondFlipTakenLeaf242
// The importer at instance depth 2 inside a generate block, the parameter read in a
// replication count, a dimension bound and a loop bound of a generate for.
package fp;
  parameter int BusWidth = 32;
  parameter int DataWidth = 64;
  parameter int WidthMultiple = DataWidth / BusWidth;
  parameter int LsbAddrBit = $clog2(WidthMultiple);
  parameter int WordSelW = WidthMultiple == 1 ? 1 : LsbAddrBit;
endpackage
module leaf import fp::*; #(parameter int K = 1) (input logic i, output logic [WordSelW:0] o);
  assign o = {(WordSelW+1){i}};
  for (genvar g = 0; g < WordSelW; g++) begin : gl
    logic [WordSelW-1:0] t;
  end
endmodule
module mid (input logic i, output logic [1:0] o);
  if (1) begin : gm
    leaf #(.K(2)) u (.i(i), .o(o));
  end
endmodule
module top (input logic i, output logic [1:0] o);
  mid m (.i(i), .o(o));
endmodule
