// § caLhsBindsUpScopes269
interface ifc #(parameter int W = 4);
  if (1) begin : g
    logic [3:0] s;
    assign s = {W{1'b1}};
  end
endinterface
module mid;
  ifc i();
endmodule
module top(output wire [3:0] o);
  logic [3:0] s;
  mid um();
  assign o = s;
endmodule
