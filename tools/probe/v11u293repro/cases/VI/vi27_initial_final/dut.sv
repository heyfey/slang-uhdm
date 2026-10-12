// § ifaceFirstSignalBindsRefs293
// Initial and final blocks read the port-first net.
interface ifc (o);
  output [7:0] o;
  wire [7:0] o;
  int n;
  assign o = 8'd2;
  initial n = o;
  final $display("%0d", o);
endinterface
module top (output logic [7:0] o);
  ifc u_if (.o(o));
endmodule
