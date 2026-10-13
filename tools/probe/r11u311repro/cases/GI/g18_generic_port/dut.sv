// § genScopeIfaceArrayElems311
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module gchild (interface p, output logic o);
  assign o = p.sig[0];
endmodule
module top (output logic [1:0] o);
  if (1) begin : g
    ifc farr [2] ();
    gchild c0 (.p(farr[0]), .o(o[0]));
    gchild c1 (.p(farr[1]), .o(o[1]));
  end
endmodule
