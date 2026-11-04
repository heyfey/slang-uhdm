// § ifaceFirstSignalBindsRefs293
// A tri net under the port declaration.
interface ifc (o, p);
  output [7:0] o;
  output [7:0] p;
  tri [7:0] o;
  tri [7:0] p;
  assign o = 8'd6;
  assign p = o;
endinterface
module top (output logic [7:0] o);
  logic [7:0] q;
  ifc u_if (.o(o), .p(q));
endmodule
