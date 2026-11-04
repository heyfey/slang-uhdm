// § ifaceFirstSignalBindsRefs293
// A process reads the port net.
interface ifc (o, p);
  output [3:0] o;
  output [3:0] p;
  wire [3:0] o;
  logic [3:0] r;
  wire [3:0] p;
  assign o = 4'd1;
  always_comb r = o;
  assign p = r;
endinterface
module top (output logic [3:0] o);
  logic [3:0] q;
  ifc u_if (.o(o), .p(q));
endmodule
