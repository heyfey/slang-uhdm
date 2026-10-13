// § genScopeIfaceArrayElems311
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module mid (output logic [1:0] o);
  if (1) begin : g
    ifc farr [2] ();
    child c0 (.p(farr[0]), .o(o[0]));
    child c1 (.p(farr[1]), .o(o[1]));
  end
endmodule
module top (output logic [3:0] o);
  for (genvar i = 0; i < 2; i++) begin : gm
    mid m (.o(o[2*i+1:2*i]));
  end
endmodule
