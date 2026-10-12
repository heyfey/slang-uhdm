// § ifaceFirstSignalBindsRefs293
// The interface instantiated inside a generate block of the parent.
interface ifc (o, p);
  output [7:0] o;
  output [7:0] p;
  wire [7:0] o;
  wire [7:0] p;
  assign o = 8'd7;
  assign p = o;
endinterface
module top (output logic [7:0] o);
  logic [7:0] q;
  if (1) begin : g
    ifc u_if (.o(o), .p(q));
  end
endmodule
