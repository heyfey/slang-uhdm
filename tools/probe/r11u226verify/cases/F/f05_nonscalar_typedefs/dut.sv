// § tfArgScalarTdWriter223 — control: formals of real, shortreal, string, chandle, event and struct typedefs, and a time typedef, in a class method
package p;
  typedef real      t_real;
  typedef shortreal t_sreal;
  typedef string    t_str;
  typedef chandle   t_ch;
  typedef struct packed { logic [3:0] a; } t_st;
  typedef time      t_time;
  class c;
    function void f(t_real a, t_sreal b, t_str d, t_ch e, t_st g, t_time h); endfunction
  endclass
endpackage
module top;
  import p::*;
endmodule
