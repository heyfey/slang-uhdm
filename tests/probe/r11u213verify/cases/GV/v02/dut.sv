// § genScopeClassVarListed206 (generate-case, a default item, the module instantiated with two selections)
class c; int x; endclass
module leaf #(parameter int K = 0) ();
  case (K)
    0: begin : k0
      c q0;
    end
    1: begin : k1
      c q1;
      logic [3:0] w;
    end
    default: begin : kd
      c qd;
    end
  endcase
endmodule
module v02 ();
  leaf #(0) a ();
  leaf #(1) b ();
  leaf #(7) d ();
endmodule
