// § ifaceElabInlineSuKeyword130
// case i01: an interface array whose interface holds an inline anonymous packed struct
interface ifc;
  struct packed { logic [1:0] a; logic b; } s;
endinterface
module top(output logic [5:0] o);
  ifc u[2]();
  assign o = {u[0].s, u[1].s};
endmodule
