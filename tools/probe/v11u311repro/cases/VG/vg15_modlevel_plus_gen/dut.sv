// § genScopeIfaceArrayElems311
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module top (output logic [3:0] o);
  ifc marr [2] ();
  child m0 (.p(marr[0]), .o(o[0]));
  child m1 (.p(marr[1]), .o(o[1]));
  if (1) begin : g
    ifc farr [2] ();
    child c0 (.p(farr[0]), .o(o[2]));
    child c1 (.p(farr[1]), .o(o[3]));
  end
endmodule
