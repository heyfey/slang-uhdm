// § unitPredefAliasOfAlias245
// an alias of a $unit int typedef on a module variable and a function formal
typedef int ui_t;
typedef ui_t ua_t;
module top(input int i, output int o);
  function automatic int f(ua_t x); return x + 1; endfunction
  ua_t v;
  assign v = i;
  assign o = f(v);
endmodule
