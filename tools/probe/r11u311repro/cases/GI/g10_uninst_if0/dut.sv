// § genScopeIfaceArrayElems311
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module top (output logic [1:0] o);
  if (0) begin : g
    ifc farr [2] ();
    child c0 (.p(farr[0]), .o(o[0]));
  end
  else begin : ge
    assign o = '0;
  end
endmodule
