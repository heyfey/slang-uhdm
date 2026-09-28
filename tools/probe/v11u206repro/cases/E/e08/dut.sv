// § genScopeClassVarListed206
class c;
endclass
module e08 #(parameter int K = 1);
  case (K)
    1: begin : g
      c q1, q2;
    end
    default: begin : h
      c r;
    end
  endcase
endmodule
