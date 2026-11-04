// § ifaceFirstSignalBindsRefs293
// Port-first interface net read by the parent through a hierarchical path.
interface ifc (o, p);
  output [7:0] o;
  output [7:0] p;
  wire [7:0] o;
  wire [7:0] p;
  assign o = 8'd12;
  assign p = o;
endinterface
module top (output logic [7:0] o, output logic [7:0] z);
  logic [7:0] q;
  ifc u_if (.o(o), .p(q));
  assign z = u_if.o + u_if.p;
endmodule
