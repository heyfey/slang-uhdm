// § ifaceFirstSignalBindsRefs293
// A delayed assign reads the port-first net.
interface ifc (o, p);
  output [7:0] o;
  output [7:0] p;
  wire [7:0] o;
  wire [7:0] p;
  assign #1 o = 8'd1;
  assign #2 p = o;
endinterface
module top (output logic [7:0] o);
  logic [7:0] q;
  ifc u_if (.o(o), .p(q));
endmodule
