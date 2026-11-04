// § ifaceFirstSignalBindsRefs293
// Scalar port-first net read in an always block.
interface ifc (o, p);
  output o;
  output p;
  wire o;
  logic r;
  wire p;
  assign o = 1'b1;
  always @* r = ~o;
  assign p = r;
endinterface
module top (output logic o);
  logic q;
  ifc u_if (.o(o), .p(q));
endmodule
