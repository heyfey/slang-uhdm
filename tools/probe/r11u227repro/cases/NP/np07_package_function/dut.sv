// § newArrayPartSelStripped227
package p;
  logic [7:0] v;
  int k;
  function automatic int f();
    int la[];
    la = new[v[k+:2]];
    return la.size();
  endfunction
endpackage
module top(output int o);
  initial o = p::f();
endmodule
