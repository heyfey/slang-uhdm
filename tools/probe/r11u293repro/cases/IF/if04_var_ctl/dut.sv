// § ifaceFirstSignalBindsRefs293
// CONTROL: a logic variable re-declaration (found among the variables).
interface ifc (o);
  output [7:0] o;
  logic [7:0] o;
  assign o = 8'd7;
endinterface
module top (output logic [7:0] o);
  ifc u_if (.o(o));
endmodule
