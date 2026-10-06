// § selLhsOpFoldFresh269
interface ifc #(parameter P = 4'd2);
  wire [7:0] w;
  assign w[3:0] = P + 4'd1;
  assign w[7:4] = 4'h0;
endinterface
module top(output wire [7:0] o);
  ifc i();
  assign o = i.w;
endmodule
