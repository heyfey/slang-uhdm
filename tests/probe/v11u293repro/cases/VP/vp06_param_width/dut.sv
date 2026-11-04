// § portViewNdaNetCellParent293
// A parameter-sized net with an initializer.
interface ifc #(parameter int W = 8) ();
  wire [W-1:0] w = '1;
  modport mp (input w);
endinterface
module sub (ifc.mp p, output logic [7:0] o);
  assign o = p.w;
endmodule
module top (output logic [7:0] o);
  ifc #(.W(8)) u_if ();
  sub u_s (.p(u_if), .o(o));
endmodule
