// § genIfaceParentAtBirth313
interface ifc (input logic clk);
  logic [7:0] sig;
  modport mp (input sig, input clk);
endinterface
interface pifc #(parameter W = 2) (input logic [W-1:0] clk);
  logic [7:0] sig;
endinterface
module top (input logic [3:0] ck, output logic o);
  if (1) begin : g
    pifc #(.W(2)) u (.clk(ck[2:1]));
  end
  assign o = 1'b0;
endmodule
