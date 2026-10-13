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
    ifc farr [2] ();
    assign farr[1].sig = 8'h3;
  end
  child c0 (.p(g.farr[1]), .o(o[0]));
  assign o[1] = g.farr[0].sig[2];
endmodule
