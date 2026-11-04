// § callResultMemberDropped411
typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
module top(input logic [3:0] x, output logic [3:0] r);
  function automatic s_t mk(logic [3:0] v);
    mk.a = v; mk.b = ~v;
  endfunction
  assign r = mk(x).b;
endmodule
