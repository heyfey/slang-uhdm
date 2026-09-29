// § hpVarSelRangeIdxNamesByPath220
interface bus;
  logic [3:0][7:0] arr;
endinterface
module sub(bus b, input logic [1:0] i, output logic [1:0] o);
  assign o = b.arr[i][1:0];
endmodule
module top(input logic [1:0] i, output logic [1:0] o);
  bus bb();
  assign bb.arr = 32'h12345678;
  sub u(.b(bb), .i(i), .o(o));
endmodule
