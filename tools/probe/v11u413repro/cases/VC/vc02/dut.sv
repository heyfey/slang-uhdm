// § classCallResultMemberRef413
class C;
  typedef struct packed { logic [3:0] s; logic [3:0] t; } p_t;
  static function p_t mk(logic [3:0] v);
    mk = {v, ~v};
  endfunction
endclass
module top(input logic [3:0] x, output logic [3:0] r);
  always_comb r = C::mk(x).s;
endmodule
