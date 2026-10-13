// § genScopeIfaceArrayElems311
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module top (output logic o);
  if (1) begin : g
    logic w;
    ifc farr [3] ();
    assign w = farr[2].sig[1];
    assign o = w;
  end
endmodule
