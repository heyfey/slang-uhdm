// § badItemLocThroughInvalid288 — CONTROL: every item binds (module, class, function, always)
module top(input logic [1:0] s, output logic [3:0] y);
  always_comb begin
    case (s)
      2'd0: y = 4'h1;
      2'd1: begin y = 4'h2; end
      default: y = 4'h0;
    endcase
  end
  function automatic int f(int k);
    case (k)
      1: return 3;
      default: begin int q; q = k; return q; end
    endcase
  endfunction
endmodule
