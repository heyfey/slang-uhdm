// § ifaceFirstSignalBindsRefs293
// An inout port declared before its net.
interface ifc (io, p);
  inout [7:0] io;
  output [7:0] p;
  wire [7:0] io;
  wire [7:0] p;
  assign p = io;
endinterface
module top (inout wire [7:0] b, output logic [7:0] q);
  ifc u_if (.io(b), .p(q));
endmodule
