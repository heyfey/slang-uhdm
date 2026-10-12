// § ifaceFirstSignalBindsRefs293
// Two instances.
interface ifc (o, p);
  output [7:0] o;
  output [7:0] p;
  wire [7:0] o;
  wire [7:0] p;
  assign o = 8'd1;
  assign p = o;
endinterface
module top (output logic [7:0] o, output logic [7:0] o2);
  logic [7:0] q, q2;
  ifc u_a (.o(o), .p(q));
  ifc u_b (.o(o2), .p(q2));
endmodule
