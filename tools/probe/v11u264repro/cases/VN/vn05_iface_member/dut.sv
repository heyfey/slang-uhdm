// § caLvTrailIdxNamesByPath264
interface ifc;
  logic [3:0] en;
endinterface
module top(input logic [3:0] a, output logic [3:0] o);
  ifc i();
  for (genvar k = 0; k < 4; k++) begin : g
    assign i.en[k] = a[k];
  end
  assign o = i.en;
endmodule
