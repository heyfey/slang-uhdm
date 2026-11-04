// § nestedDeepInstStub307
interface ifc; logic w; endinterface
module outer (input logic a, output logic y);
  module inner (ifc p, output logic o); assign o = p.w; endmodule
  ifc u_if ();
  assign u_if.w = a;
  if (1) begin : g
    inner u_in (.p(u_if), .o(y));
  end
endmodule
module dut (input logic a, output logic y);
  outer u1 (.a(a), .y(y));
endmodule
