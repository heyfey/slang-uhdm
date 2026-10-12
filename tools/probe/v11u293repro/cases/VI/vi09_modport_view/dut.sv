// § ifaceFirstSignalBindsRefs293
// Port-first net listed by a modport used by a module port.
interface ifc (o, p);
  output [7:0] o;
  output [7:0] p;
  wire [7:0] o;
  wire [7:0] p;
  assign o = 8'd2;
  assign p = o;
  modport mp (input o, input p);
endinterface
module sub (ifc.mp m, output logic [7:0] z);
  assign z = m.o ^ m.p;
endmodule
module top (output logic [7:0] o, output logic [7:0] z);
  logic [7:0] q;
  ifc u_if (.o(o), .p(q));
  sub u_s (.m(u_if), .z(z));
endmodule
