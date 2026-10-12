// § ifaceFirstSignalBindsRefs293
// Several declarators in the port and net declarations.
interface ifc (o, p);
  output [7:0] o, p;
  wire [7:0] o, p;
  assign o = 8'd9;
  assign p = o;
endinterface
module top (output logic [7:0] o);
  logic [7:0] q;
  ifc u_if (.o(o), .p(q));
endmodule
