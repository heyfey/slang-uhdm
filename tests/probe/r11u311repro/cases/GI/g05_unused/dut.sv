// § genScopeIfaceArrayElems311
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module top (output logic o);
  if (1) begin : g
    ifc farr [2] ();
  end
  assign o = 1'b0;
endmodule
