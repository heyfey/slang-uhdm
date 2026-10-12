// § portViewNdaNetCellParent293
// The interface body reads the assigned net too.
interface ifc ();
  wire [7:0] w = 8'd9;
  wire [7:0] y;
  assign y = w + 8'd1;
  modport mp (input w, input y);
endinterface
module sub (ifc.mp p, output logic [7:0] o);
  assign o = p.w & p.y;
endmodule
module top (output logic [7:0] o);
  ifc u_if ();
  sub u_s (.p(u_if), .o(o));
endmodule
