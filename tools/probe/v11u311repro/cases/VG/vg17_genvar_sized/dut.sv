// § genScopeIfaceArrayElems311
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module top (output logic [2:0] o);
  for (genvar i = 0; i < 2; i++) begin : gf
    ifc farr [i+1] ();
    child c0 (.p(farr[0]), .o(o[i]));
  end
  assign o[2] = 1'b0;
endmodule
