// § portViewNdaNetCellParent293
// A for-generate loop instantiating the module with the modport port twice.
interface ifc ();
  wire [7:0] w = 8'd2, x = 8'd4;
  modport mp (input w, input x);
endinterface
module sub (ifc.mp p, output logic [7:0] o);
  assign o = p.w + p.x;
endmodule
module top (output logic [7:0] o0, output logic [7:0] o1);
  ifc u_if ();
  logic [7:0] oo [2];
  for (genvar i = 0; i < 2; i++) begin : g
    sub u_s (.p(u_if), .o(oo[i]));
  end
  assign o0 = oo[0];
  assign o1 = oo[1];
endmodule
