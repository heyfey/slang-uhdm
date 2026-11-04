// § ifaceFirstSignalBindsRefs293
// Positional port connection.
interface ifc (o, p);
  output [7:0] o;
  output [7:0] p;
  wire [7:0] o;
  wire [7:0] p;
  assign o = 8'd1;
  assign p = ~o;
endinterface
module top (output logic [7:0] o);
  logic [7:0] q;
  ifc u_if (o, q);
endmodule
