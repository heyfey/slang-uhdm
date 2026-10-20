// § genGateTermGenNetBind418
module m #(parameter K = 1) (input a, output y);
  case (K)
    1: begin : c1
      wire t;
      not n1 (t, a);
      buf b1 (y, t);
    end
    default: begin : c2
      assign y = a;
    end
  endcase
endmodule
