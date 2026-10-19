// § unitTdClassPropAliasName410
typedef int t_t;
typedef logic [3:0] n_t;
class C;
  t_t a;
  n_t b;
  static t_t c;
endclass
module top; C c = new; endmodule
