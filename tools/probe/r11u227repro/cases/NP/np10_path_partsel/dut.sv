// § newArrayPartSelStripped227
package p;
typedef struct packed { logic [7:0] f; } s_t;
class c;
  s_t s; int k;
  function void f();
    int la[];
    la = new[s.f[1:0]];
    la = new[s.f[k+:2]];
  endfunction
endclass
endpackage
module top; endmodule
