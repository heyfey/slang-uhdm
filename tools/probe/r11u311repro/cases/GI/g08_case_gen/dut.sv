// § genScopeIfaceArrayElems311
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module top #(parameter int K = 1) (output logic [1:0] o);
  case (K)
    0: begin : g0 assign o = '0; end
    default: begin : gd
      ifc farr [2] ();
      child c0 (.p(farr[0]), .o(o[0]));
      child c1 (.p(farr[1]), .o(o[1]));
    end
  endcase
endmodule
