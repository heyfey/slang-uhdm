// § nestedPosInstUdp307
interface ifc; logic w; endinterface
module outer (input logic a, output logic y);
  module inner (output logic o, ifc p); assign o = p.w; endmodule
  ifc u_if ();
  assign u_if.w = a;
  inner u_in (y, u_if);
endmodule
module dut (input logic a, output logic y);
  outer u1 (.a(a), .y(y));
endmodule
