// § ifaceFirstSignalBindsRefs293
// Parameterized width, two instances.
interface ifc #(parameter int W = 4) (o, p);
  output [W-1:0] o;
  output [W-1:0] p;
  wire [W-1:0] o;
  wire [W-1:0] p;
  assign o = '1;
  assign p = o;
endinterface
module top (output logic [3:0] o, output logic [7:0] o2);
  logic [3:0] q;
  logic [7:0] q2;
  ifc u_a (.o(o), .p(q));
  ifc #(.W(8)) u_b (.o(o2), .p(q2));
endmodule
