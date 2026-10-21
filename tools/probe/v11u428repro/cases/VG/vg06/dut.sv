// § uninstDefGenRegionCaUnlisted428
interface ifc(input [3:0] a);
  wire [3:0] o;
  generate
    if (1) begin: g end
    assign o = a;
  endgenerate
endinterface
module top; endmodule
