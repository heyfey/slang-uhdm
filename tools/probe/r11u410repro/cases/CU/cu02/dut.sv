// § unitTdClassPropAliasName410
typedef logic [3:0] n_t;
typedef string s_t;
typedef bit b_t;
class C;
  n_t a;
  s_t b;
  rand b_t c;
endclass
module top;
  C h;
  initial h = new;
endmodule
