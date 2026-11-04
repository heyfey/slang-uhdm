// § genCaReplParentBoundLhs267
interface ifc #(parameter int W = 5) ();
  logic [W-1:0] s;
  if (1) begin : g
    assign s = {W{1'b1}};
  end
endinterface
module top;
  ifc u_i();
endmodule
