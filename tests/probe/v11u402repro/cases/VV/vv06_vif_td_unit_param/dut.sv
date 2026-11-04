// § virtIfaceTd402
interface I #(parameter W = 1); logic [W-1:0] a; endinterface
typedef virtual I #(4) VI4;
module top;
  VI4 v;
endmodule
