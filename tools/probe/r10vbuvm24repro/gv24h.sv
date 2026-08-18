// r10vbuvm24repro/gv24h.sv — more homes: a PARAMETERIZED class (two
// specialisations), a generate-if / generate-case, a constant-function call in
// a localparam initialiser, and a fork/join body.  MEASUREMENT ONLY.
package px24;
  function automatic int x3(int a = 1, int b = 2, int c = 3); return a + b + c; endfunction

  class gen24 #(parameter int P = 1);
    function int gm(int a = 1, int b = 2, int c = 3); return a + b + c + P; endfunction
    function int run24();
      int r = 0;
      r += gm(1,,3);
      r += x3(P,,3);
      return r;
    endfunction
  endclass
endpackage

module topx24;
  import px24::*;
  localparam int LP = x3(1,,3);
  gen24 #(1) g1;
  gen24 #(2) g2;
  int rr;

  if (1) begin : gif
    initial rr = x3(1,,3);
  end

  case (1)
    1: begin : gcase
      initial rr = x3(2,,3);
    end
  endcase

  initial begin
    g1 = new();
    g2 = new();
    rr += g1.run24();
    rr += g2.run24();
    fork
      rr = x3(3,,3);
    join_none
  end
endmodule
