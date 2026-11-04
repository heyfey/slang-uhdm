// § nestedDefSecondBodyReadsRep307
interface ifc; logic w; modport mp (input w); endinterface
module outer (ifc.mp p, output logic y);
  module inner (ifc.mp q, output logic o); assign o = q.w; endmodule
  inner u_i (.q(p), .o(y));
endmodule
module dut (input logic [1:0] a, output logic [1:0] y);
  ifc u_if0 ();
  ifc u_if1 ();
  assign u_if0.w = a[0];
  assign u_if1.w = a[1];
  outer u_o (.p(u_if0), .y(y[0]));
  outer u_p (.p(u_if1), .y(y[1]));
endmodule
