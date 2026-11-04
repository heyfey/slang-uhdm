// § timeNetKeywordOnly406v
typedef time signed ts_t;
module top;
  ts_t v;
  function time unsigned f(input time signed a);
    return a;
  endfunction
  initial v = f(3);
endmodule
