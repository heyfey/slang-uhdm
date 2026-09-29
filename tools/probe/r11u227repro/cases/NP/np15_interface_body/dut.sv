// § newArrayPartSelStripped227
interface ifc;
  logic [7:0] v;
  int k;
  function automatic int f();
    int la[];
    la = new[v[k+:2]];
    return la.size();
  endfunction
endinterface
module top(output int o);
  ifc i();
  initial o = i.f();
endmodule
