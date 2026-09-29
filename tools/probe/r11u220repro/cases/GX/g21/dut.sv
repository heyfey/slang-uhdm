// § hpVarSelRangeIdxNamesByPath220
interface bus; logic [1:0][3:0] pg; logic [1:0] ix; endinterface
module top(input logic [7:0] din, input logic [1:0] ix, output logic [1:0] o);
  bus b();
  assign b.pg = din;
  assign b.ix = ix;
  assign o = b.pg[b.ix][1:0];
endmodule
