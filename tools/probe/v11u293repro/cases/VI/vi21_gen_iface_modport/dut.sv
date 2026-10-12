// § ifaceFirstSignalBindsRefs293
// A port-first interface inside a generate block with a modport consumer.
interface ifc (o, p);
  output [7:0] o;
  output [7:0] p;
  wire [7:0] o;
  wire [7:0] p;
  assign o = 8'd5;
  assign p = o;
  modport mp (input o);
endinterface
module sub (ifc.mp m, output logic [7:0] z);
  assign z = m.o;
endmodule
module top (output logic [7:0] o, output logic [7:0] z);
  logic [7:0] q;
  if (1) begin : g
    ifc u_if (.o(o), .p(q));
    sub u_s (.m(u_if), .z(z));
  end
endmodule
