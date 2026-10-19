// § unitTdClassPropAliasName410
typedef int t_t;
typedef bit [7:0] b_t;
module top;
  class D;
    t_t a;
    b_t b;
  endclass
  D d = new;
endmodule
