// § enumTdLastWriter214 — an explicit $unit import of the enum TYPE (not a value) with a $unit class and a module reading it
package p;
  typedef enum logic [3:0] {E0 = 1, E1 = 3, E2 = 7} e_t;
endpackage
import p::e_t;
class holder_c;
  e_t h;
  function e_t get(); return h; endfunction
endclass
module top(output int o);
  e_t s = p::E2;
  assign o = int'(s);
endmodule
