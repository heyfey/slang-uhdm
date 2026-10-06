// § genCaReplParentBoundLhs267
interface ifc #(parameter int W = 4);
  logic [3:0] s;
  if (1) begin : g
    assign s = {W{1'b1}};
  end
endinterface
module top(output logic [3:0] o);
  logic [3:0] s;
  ifc u_i();
  assign s = u_i.s;
  assign o = s;
endmodule
