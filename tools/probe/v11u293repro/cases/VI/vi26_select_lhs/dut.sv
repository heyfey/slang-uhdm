// § ifaceFirstSignalBindsRefs293
// Bit and part selects of the port-first net on assignment left sides.
interface ifc (o, p);
  output [7:0] o;
  output [7:0] p;
  wire [7:0] o;
  wire [7:0] p;
  assign o[0] = 1'b1;
  assign o[7:1] = 7'd0;
  assign p = {o[3:0], o[7:4]};
endinterface
module top (output logic [7:0] o);
  logic [7:0] q;
  ifc u_if (.o(o), .p(q));
endmodule
