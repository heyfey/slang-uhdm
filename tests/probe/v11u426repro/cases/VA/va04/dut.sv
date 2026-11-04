// § unitFixedArrTdAliasClone426
typedef int ua_t [4];
typedef ua_t ub_t;
function int sum(ub_t a);
  return a[0] + a[3];
endfunction
module test;
  ub_t v;
  initial $display(sum(v));
endmodule
