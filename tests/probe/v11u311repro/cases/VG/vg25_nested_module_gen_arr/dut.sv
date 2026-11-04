// § genScopeIfaceArrayElems311
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module top (output logic [1:0] o);
  module inner (output logic [1:0] oi);
    if (1) begin : g
      ifc farr [2] ();
      child c0 (.p(farr[0]), .o(oi[0]));
      child c1 (.p(farr[1]), .o(oi[1]));
    end
  endmodule
  inner ii (.oi(o));
endmodule
