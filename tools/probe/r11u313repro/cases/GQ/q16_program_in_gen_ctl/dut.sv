// § genIfaceConnGenScopeName313
interface ifc (input logic clk);
  logic [7:0] sig;
  modport mp (input sig, input clk);
endinterface
program prg (input logic clk);
  initial $display(clk);
endprogram
module top (input logic [1:0] ck, output logic o);
  if (1) begin : g
    prg p (.clk(ck[1]));
  end
  assign o = 1'b0;
endmodule
