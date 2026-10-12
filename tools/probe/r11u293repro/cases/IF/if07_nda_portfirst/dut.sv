// § ifaceFirstSignalBindsRefs293
// A body net declaration assignment under a port declaration.
interface ifc (o, p);
  output [31:0] o;
  output [31:0] p;
  wire [31:0] o = 32'd12;
  wire [31:0] p;
  assign p = o;
endinterface
module top (output logic [31:0] o);
  logic [31:0] q;
  ifc u_if (.o(o), .p(q));
endmodule
