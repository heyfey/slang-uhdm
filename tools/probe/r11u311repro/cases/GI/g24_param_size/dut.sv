// § genScopeIfaceArrayElems311
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module top #(parameter int N = 3) (output logic [N-1:0] o);
  if (1) begin : g
    ifc farr [N] ();
    for (genvar i = 0; i < N; i++) begin : gc
      child c (.p(farr[i]), .o(o[i]));
    end
  end
endmodule
