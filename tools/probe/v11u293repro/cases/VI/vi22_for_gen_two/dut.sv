// § ifaceFirstSignalBindsRefs293
// A for-generate loop with two port-first interface instances.
interface ifc (o, p);
  output [3:0] o;
  output [3:0] p;
  wire [3:0] o;
  wire [3:0] p;
  assign o = 4'd5;
  assign p = ~o;
endinterface
module top (output logic [3:0] o0, output logic [3:0] o1);
  logic [3:0] oo [2], qq [2];
  for (genvar i = 0; i < 2; i++) begin : g
    ifc u_if (.o(oo[i]), .p(qq[i]));
  end
  assign o0 = oo[0];
  assign o1 = qq[1];
endmodule
