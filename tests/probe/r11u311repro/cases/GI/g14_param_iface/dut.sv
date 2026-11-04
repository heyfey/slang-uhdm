// § genScopeIfaceArrayElems311
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
interface pif #(parameter int W = 4);
  logic [W-1:0] d;
  modport mp (input d);
endinterface
module pchild (pif.mp p, output logic o);
  assign o = p.d[0];
endmodule
module top (output logic [1:0] o);
  if (1) begin : g
    pif #(.W(6)) farr [2] ();
    pchild c0 (.p(farr[0]), .o(o[0]));
    pchild c1 (.p(farr[1]), .o(o[1]));
  end
endmodule
