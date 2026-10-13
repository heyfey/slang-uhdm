// § genScopeIfaceArrayElems311
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module top (output logic [3:0] o);
  for (genvar i = 0; i < 2; i++) begin : gf
    ifc farr [2] ();
    for (genvar j = 0; j < 2; j++) begin : gj
      child c (.p(farr[j]), .o(o[2*i+j]));
    end
  end
endmodule
