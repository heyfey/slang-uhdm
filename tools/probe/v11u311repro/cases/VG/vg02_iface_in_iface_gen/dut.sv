// § genScopeIfaceArrayElems311
interface leaf;
  logic [7:0] sig;
endinterface
interface outer;
  if (1) begin : g
    leaf farr [2] ();
  end
endinterface
module top (output logic o);
  outer u ();
  assign o = u.g.farr[1].sig[0];
endmodule
