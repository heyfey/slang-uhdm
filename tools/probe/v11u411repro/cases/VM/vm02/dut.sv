// § callResultMemberDropped411
package pk;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  function automatic s_t mk(logic [3:0] v);
    mk.a = v; mk.b = ~v;
  endfunction
endpackage
module top(input logic [3:0] x, output logic [3:0] r);
  always_comb r = pk::mk(x).a;
endmodule
