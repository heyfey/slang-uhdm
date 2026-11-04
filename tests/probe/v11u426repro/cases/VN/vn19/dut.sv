// § namedTypeLocalTfItemOutsideClass426
typedef enum logic [1:0] {S0, S1, S2} st_t;
module top(input logic clk, input logic [1:0] i, output logic [1:0] o);
  function st_t nxt;
    input st_t s;
    st_t t;
    t = st_t'(s + 1);
    nxt = t;
  endfunction
  always_ff @(posedge clk) o <= nxt(st_t'(i));
endmodule
