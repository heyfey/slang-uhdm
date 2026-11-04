// § newArrayPartSelStripped227
package p;
typedef struct packed { logic [7:0] v; logic [3:0] u; } s_t;
class c;
  function void f();
    int la[];
    s_t s;
    la = new[s.v[3:0]];
    la = new[s.u[1:0] + 1];
  endfunction
endclass
endpackage
module top; endmodule
