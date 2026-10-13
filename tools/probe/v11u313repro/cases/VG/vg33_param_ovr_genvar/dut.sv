// § genIfaceHcInnerRefUnbound313
interface ifp #(parameter int W = 1) (input logic clk);
  logic [W-1:0] sig;
endinterface
module top (input logic [2:0] ck, input logic a, output logic [1:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    ifp #(.W(i+1)) u (.clk(ck[i] & a));
    assign o[i] = u.sig[0];
  end
endmodule
