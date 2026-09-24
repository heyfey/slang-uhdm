// § ifaceElabInlineSuKeyword130
// case i02: an interface instantiated inside a generate block, inline signed struct
interface ifc;
  struct packed signed { logic [1:0] a; logic [1:0] b; } s;
endinterface
module top(output logic [3:0] o);
  if (1) begin : g
    ifc u();
  end
  assign o = g.u.s;
endmodule
