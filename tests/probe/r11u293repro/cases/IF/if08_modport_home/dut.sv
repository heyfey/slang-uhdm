// § ifaceFirstSignalBindsRefs293
// A modport in the home view.
interface ifc (o, p);
  output [7:0] o;
  output [7:0] p;
  wire [7:0] o;
  wire [7:0] p;
  assign o = 8'd2;
  assign p = o;
  modport mp (output o, output p);
endinterface
module top (output logic [7:0] o);
  logic [7:0] q;
  ifc u_if (.o(o), .p(q));
endmodule
