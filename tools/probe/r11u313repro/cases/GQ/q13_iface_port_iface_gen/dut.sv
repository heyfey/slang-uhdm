// § genIfaceConnGenScopeName313
interface ifc (input logic clk);
  logic [7:0] sig;
  modport mp (input sig, input clk);
endinterface
interface inner (input logic clk);
  logic s;
endinterface
interface holder (inner i);
  logic t;
endinterface
module top (input logic clk, output logic o);
  if (1) begin : g
    inner n (.clk(clk));
    holder h (.i(n));
  end
  assign o = 1'b0;
endmodule
