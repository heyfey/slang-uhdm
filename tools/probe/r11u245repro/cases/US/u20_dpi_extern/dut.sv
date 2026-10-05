// § unitTdLawS245
// $unit typedefs in a DPI import, an out-of-body class method and a static class function
typedef int ui_t;
typedef string us_t;
import "DPI-C" function ui_t c_f(input ui_t a, input us_t s);
class c;
  extern function ui_t g(ui_t a);
  static function us_t h(us_t s); return s; endfunction
endclass
function ui_t c::g(ui_t a);
  ui_t t;
  t = a;
  return t;
endfunction
module top;
  c o;
  ui_t r;
  initial r = c_f(1, "x");
endmodule
