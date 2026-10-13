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
    if (1) begin : gi
      ifc farr [2] ();
      child c0 (.p(farr[0]), .o(o[2*i]));
      child c1 (.p(farr[1]), .o(o[2*i+1]));
    end
  end
endmodule
