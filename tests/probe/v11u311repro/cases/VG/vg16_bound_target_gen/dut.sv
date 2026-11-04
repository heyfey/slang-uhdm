// § genScopeIfaceArrayElems311
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module tgt (output logic [1:0] o);
  assign o = '0;
endmodule
module mon (output logic [1:0] m);
  if (1) begin : g
    ifc farr [2] ();
    child c0 (.p(farr[0]), .o(m[0]));
    child c1 (.p(farr[1]), .o(m[1]));
  end
endmodule
module top (output logic [1:0] o, output logic [1:0] m);
  tgt t (.o(o));
  bind tgt mon mb (.m());
endmodule
