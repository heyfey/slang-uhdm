// § callResultMemberDropped411
typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
function automatic s_t mk(logic [3:0] v);
  mk = {v, ~v};
endfunction
module top(input logic [3:0] x, output logic [3:0] r, output logic [3:0] q);
  assign r = mk(x).a;
  always_comb q = mk(x).b ^ mk(~x).a;
endmodule
