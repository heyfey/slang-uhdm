// § ifaceFirstSignalBindsRefs293
// An unpacked-array port declared before its net.
interface ifc (o, p);
  output [3:0] o [2];
  output [3:0] p;
  wire [3:0] o [2];
  wire [3:0] p;
  assign o[0] = 4'd1;
  assign o[1] = 4'd2;
  assign p = o[0] + o[1];
endinterface
module top (output logic [3:0] q);
  wire [3:0] oo [2];
  ifc u_if (.o(oo), .p(q));
endmodule
