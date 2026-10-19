// § unitTdClassPropAliasName410
typedef string s_t;
typedef real r_t;
typedef int t_t;
class B;
  t_t x;
endclass
class C extends B;
  s_t a;
  r_t b;
  rand t_t c;
  t_t d [2];
  local t_t e;
endclass
module top; C c = new; endmodule
