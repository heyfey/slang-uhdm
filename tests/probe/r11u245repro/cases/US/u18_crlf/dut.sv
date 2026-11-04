// § unitTdLawS245
// a CRLF file with $unit string, int and vector typedefs
typedef string us_t;
typedef int ui_t;
typedef logic [3:0] nib_t;
module top;
  us_t s;
  ui_t i;
  nib_t n;
  function automatic us_t f(ui_t a); us_t r; r = "x"; return r; endfunction
endmodule
