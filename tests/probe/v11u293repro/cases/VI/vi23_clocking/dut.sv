// § ifaceFirstSignalBindsRefs293
// A clocking block samples the port-first net.
interface ifc (clk, o);
  input clk;
  output [7:0] o;
  wire clk;
  wire [7:0] o;
  assign o = 8'd3;
  clocking cb @(posedge clk);
    input o;
  endclocking
endinterface
module top (input logic clk, output logic [7:0] o);
  ifc u_if (.clk(clk), .o(o));
endmodule
