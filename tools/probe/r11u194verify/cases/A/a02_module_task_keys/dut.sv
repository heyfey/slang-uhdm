// § assocPromotedBoundAtBracket183: associative dimensions keyed by a typedef, an enum and string in a module task and function (a module: no package above the declaration)
module top (output int o);
  typedef enum {K0, K1} k_e;
  typedef logic [7:0] t_t;
  task automatic t();
    int mt[t_t];
    int me[k_e];
    mt[8'd1] = 1;
    me[K1] = 2;
  endtask
  function automatic int f();
    string m[string];
    m["x"] = "y";
    return m.num();
  endfunction
  initial begin t(); o = f(); end
endmodule
