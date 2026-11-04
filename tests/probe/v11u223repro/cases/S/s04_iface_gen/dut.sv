// § ndaAdjSizeFoldSized223
interface ifc;
  logic [5:0][2:0] lp;
  wire [3:0] w = $size(lp);
endinterface
module dut (output logic [7:0] o1, o2);
  ifc i();
  bit [3:0][1:0] bp;
  if (1) begin : g
    wire [2:0] w = $size(bp);
    assign o1 = w;
  end
  assign o2 = i.w;
endmodule
