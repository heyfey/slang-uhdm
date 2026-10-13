// § genScopeIfaceArrayElems311
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module top (output logic [1:0] o);
  if (1) begin : g
    ifc fa [2] ();
    ifc fb [2] ();
    child c0 (.p(fb[0]), .o(o[0]));
    child c1 (.p(fa[1]), .o(o[1]));
  end
endmodule
