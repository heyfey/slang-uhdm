// § caCallArgCastAbstains232v
package q;
  typedef logic [0:2] mask_t;
  function automatic int unsigned cnt(mask_t cfg);
    int unsigned r = 0;
    for (int i = 0; i < 3; i++) if (cfg[i]) r++;
    return r;
  endfunction
  function automatic int unsigned w(int unsigned x);
    return x + 1;
  endfunction
  function automatic int unsigned w2(logic [7:0] x, int unsigned y);
    return x + y;
  endfunction
endpackage
// a signed cast and a $unsigned call around the parameter argument
module sub #(parameter int unsigned N = 1) (output int o, output int p);
  assign o = q::w(signed'(N));
  assign p = q::w($unsigned(N));
endmodule
module top(output int o, output int p);
  sub #(.N(5)) u (.o(o), .p(p));
endmodule
