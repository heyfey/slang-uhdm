// § ifaceFirstSignalBindsRefs293
// A port left unconnected by the instance.
interface ifc (o, p);
  output [7:0] o;
  output [7:0] p;
  wire [7:0] o;
  wire [7:0] p;
  assign o = 8'd1;
  assign p = o;
endinterface
module top (output logic [7:0] o);
  ifc u_if (.o(o), .p());
endmodule
