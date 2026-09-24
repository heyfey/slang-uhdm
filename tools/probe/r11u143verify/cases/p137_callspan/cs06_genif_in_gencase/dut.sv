// § constCallNameSpan137
// case cs06: a call in a generate-if condition inside a generate-case item
module top #(parameter int M = 1) (output logic [3:0] o);
  function automatic int f(input int x); return x * 3; endfunction
  case (M)
    1: begin : c1
      if (f(M) == 3) begin : g
        assign o = 4'd7;
      end else begin : h
        assign o = 4'd8;
      end
    end
    default: begin : cd
      assign o = 4'd0;
    end
  endcase
endmodule
