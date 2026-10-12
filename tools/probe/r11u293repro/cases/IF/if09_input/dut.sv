// § ifaceFirstSignalBindsRefs293
// An input port read by an assign.
interface ifc (i, o);
  input [7:0] i;
  output [7:0] o;
  wire [7:0] i;
  wire [7:0] o;
  assign o = i;
endinterface
module top (input logic [7:0] i, output logic [7:0] o);
  ifc u_if (.i(i), .o(o));
endmodule
