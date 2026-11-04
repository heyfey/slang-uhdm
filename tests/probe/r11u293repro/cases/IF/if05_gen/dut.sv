// § ifaceFirstSignalBindsRefs293
// A generate block reads the port net.
interface ifc (o, p);
  output [7:0] o;
  output [7:0] p;
  wire [7:0] o;
  wire [7:0] p;
  assign o = 8'd9;
  if (1) begin : g
    assign p = o;
  end
endinterface
module top (output logic [7:0] o);
  logic [7:0] q;
  ifc u_if (.o(o), .p(q));
endmodule
