// § ifaceFirstSignalBindsRefs293
// An input port read by always_ff and an assign.
interface ifc (clk, i, o);
  input clk;
  input [7:0] i;
  output [7:0] o;
  wire clk;
  wire [7:0] i;
  wire [7:0] o;
  logic [7:0] r;
  always_ff @(posedge clk) r <= i;
  assign o = r + i;
endinterface
module top (input logic clk, input logic [7:0] i, output logic [7:0] o);
  ifc u_if (.clk(clk), .i(i), .o(o));
endmodule
