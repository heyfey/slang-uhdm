// § genCaseItemUnnamed152
module child #(parameter int S = 1) (output logic o);
  case (S)
    1: begin : one
      wire w = 1'b1;
      assign o = w;
    end
    default: begin : other
      assign o = 1'b0;
    end
  endcase
endmodule
module top(output logic o, output logic p);
  child #(.S(1)) a(.o(o));
  child #(.S(2)) b(.o(p));
endmodule
