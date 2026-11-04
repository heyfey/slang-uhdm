// § unitPredefTd245
// $unit typedefs of time, shortreal, int signed and an alias of an int typedef
typedef time ut_t;
typedef shortreal usr_t;
typedef int signed uis_t;
typedef int ui_t;
typedef ui_t ua_t;
module top;
  ut_t t;
  usr_t s;
  uis_t i;
  ua_t a;
  function automatic ua_t f(ui_t x); ua_t y; y = x; return y; endfunction
endmodule
