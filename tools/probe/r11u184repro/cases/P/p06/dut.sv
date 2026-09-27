// § memberSelParenIdxSpan184: a class method's member path and a function body's member select with parenthesized indices
typedef struct packed { logic [7:0] f; } s_t;
module top;
  class C;
    s_t h;
    function logic g(int k);
      return h.f[(k)];
    endfunction
  endclass
  function automatic logic fm(s_t x, int k);
    return x.f[(k + 1)];
  endfunction
  logic y;
  s_t s;
  initial y = fm(s, 2);
endmodule
