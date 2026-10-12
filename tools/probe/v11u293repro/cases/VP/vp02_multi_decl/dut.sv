// § portViewNdaNetCellParent293
// Two declarators with initializers.
interface ifc ();
  wire [7:0] w = 8'd1, x = 8'd2;
  modport mp (input w, input x);
endinterface
module sub (ifc.mp p, output logic [7:0] o);
  assign o = p.w + p.x;
endmodule
module top (output logic [7:0] o);
  ifc u_if ();
  sub u_s (.p(u_if), .o(o));
endmodule
