// § genScopeIfaceArrayElems311
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
program prg (ifc.mp p);
  initial $display(p.sig);
endprogram
module top;
  if (1) begin : g
    ifc farr [2] ();
    prg p0 (.p(farr[0]));
  end
endmodule
