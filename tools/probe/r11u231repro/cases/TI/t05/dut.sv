// § topPkgTdInstanceTop231 — control: the same shape in $unit (no package listing)
typedef enum {A0, A1} a_e;
typedef a_e b_t;
class c;
  extern function void set(b_t v);
endclass
function void c::set(b_t v);
endfunction
module top;
  c h;
endmodule
