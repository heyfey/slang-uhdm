// § ifaceFirstSignalBindsRefs293
// Signed port declaration and signed net.
interface ifc (o, p);
  output signed [7:0] o;
  output signed [7:0] p;
  wire signed [7:0] o;
  wire signed [7:0] p;
  assign o = -8'sd3;
  assign p = o >>> 1;
endinterface
module top (output logic signed [7:0] o);
  logic signed [7:0] q;
  ifc u_if (.o(o), .p(q));
endmodule
