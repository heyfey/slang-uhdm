// § ifaceElabInlineSuKeyword130
// case i03: an interface with an inline UNPACKED struct signal
interface ifc;
  struct { logic [1:0] a; logic b; } s;
endinterface
module top(output logic [1:0] o);
  ifc u();
  assign o = u.s.a;
endmodule
