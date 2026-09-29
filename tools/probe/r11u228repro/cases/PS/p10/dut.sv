// § parseViewSizeExprEval228 — an interface net, a program net and a net in an interface instantiated twice
interface ifc #(parameter int W = 2);
  bit [W-1:0][3:0] ib;
  wire [7:0] w = $size(ib, 2);
endinterface
program pg (output logic [7:0] po);
  bit [2:0][1:0] pb;
  wire [7:0] pw = $size(pb);
  assign po = pw;
endprogram
module dut (output logic [7:0] o1, o2, o3);
  ifc #(.W(3)) i1();
  ifc #(.W(5)) i2();
  pg p (.po(o3));
  assign o1 = i1.w; assign o2 = i2.w;
endmodule
