// § tfSigningSpanFollowsCompilePath200
typedef byte unsigned ub_t;
typedef logic signed [7:0] sl_t;
module s02(input ub_t a, output sl_t y);
  typedef struct packed { shortint unsigned m; byte signed n; } st_t;
  st_t s;
  function automatic ub_t f(input sl_t x, input int unsigned k);
    ub_t r;
    r = x + k;
    return r;
  endfunction
  function automatic reg signed [3:0] g(input reg unsigned [3:0] z, input logic signed w);
    return z + w;
  endfunction
  assign y = f(sl_t'(a), 3) + g(a[3:0], a[0]);
endmodule
