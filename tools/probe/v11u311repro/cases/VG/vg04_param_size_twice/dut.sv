// § genScopeIfaceArrayElems311
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module mid #(parameter int N = 2) (output logic [N-1:0] o);
  if (N > 0) begin : g
    ifc farr [N] ();
    for (genvar k = 0; k < N; k++) begin : gk
      child c (.p(farr[k]), .o(o[k]));
    end
  end
endmodule
module top (output logic [4:0] o);
  mid #(.N(2)) m2 (.o(o[1:0]));
  mid #(.N(3)) m3 (.o(o[4:2]));
endmodule
