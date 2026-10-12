// § ifaceFirstSignalBindsRefs293
// The interface instantiated inside another interface.
interface ifc (o, p);
  output [7:0] o;
  output [7:0] p;
  wire [7:0] o;
  wire [7:0] p;
  assign o = 8'd8;
  assign p = o;
endinterface
interface outer (output logic [7:0] x);
  logic [7:0] q;
  ifc u_in (.o(x), .p(q));
endinterface
module top (output logic [7:0] x);
  outer u_o (.x(x));
endmodule
