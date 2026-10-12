// § ifaceFirstSignalBindsRefs293
// The port declaration comes from a macro.
`define PD(n) output [7:0] n;
interface ifc (o, p);
  `PD(o)
  `PD(p)
  wire [7:0] o;
  wire [7:0] p;
  assign o = 8'd4;
  assign p = o;
endinterface
module top (output logic [7:0] o);
  logic [7:0] q;
  ifc u_if (.o(o), .p(q));
endmodule
