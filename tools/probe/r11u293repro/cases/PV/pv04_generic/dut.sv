// § portViewNdaNetCellParent293
// A generic interface port (all modports listed).
interface ifc ();
  wire [7:0] w = 8'd5;
  modport mp (input w);
endinterface
module sub (interface p, output logic [7:0] o);
  assign o = p.w;
endmodule
module top (output logic [7:0] o);
  ifc u_if ();
  sub u_s (.p(u_if), .o(o));
endmodule
