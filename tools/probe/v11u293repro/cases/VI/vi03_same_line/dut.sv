// § ifaceFirstSignalBindsRefs293
// Port declaration and net declaration on one line.
interface ifc (o, p);
  output [7:0] o; wire [7:0] o;
  output [7:0] p; wire [7:0] p;
  assign o = 8'd3;
  assign p = o;
endinterface
module top (output logic [7:0] o);
  logic [7:0] q;
  ifc u_if (.o(o), .p(q));
endmodule
