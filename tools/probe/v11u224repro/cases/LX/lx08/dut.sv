// § hpLvSelIdxNamesByPath224
interface ifc;
  typedef struct packed { logic [3:0][7:0] arr; logic v; } s_t;
  s_t s;
  function automatic void f(logic [1:0] i, logic [1:0] d);
    s.arr[i][1:0] = d;
  endfunction
endinterface
module top(output int o);
  ifc u();
  initial begin u.f(1, 2); o = u.s; end
endmodule
