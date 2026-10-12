// § ifaceFirstSignalBindsRefs293
// Port declarations above the body nets; assigns read and write them.
interface ifc (o, p);
  output [31:0] o;
  output [31:0] p;
  wire [31:0] o;
  wire [31:0] p;
  assign o = 32'd12;
  assign p = o;
endinterface
module top (output logic [31:0] o);
  logic [31:0] q;
  ifc u_if (.o(o), .p(q));
endmodule
