// § genScopeIfaceArrayElems311
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module top #(parameter int S = 1) (output logic [3:0] o);
  case (S)
    0: begin : g0
      ifc a [2] ();
    end
    1: begin : g1
      ifc a [2] ();
      ifc b [2] ();
      child c0 (.p(a[0]), .o(o[0]));
      child c1 (.p(a[1]), .o(o[1]));
      child c2 (.p(b[0]), .o(o[2]));
      child c3 (.p(b[1]), .o(o[3]));
    end
  endcase
endmodule
