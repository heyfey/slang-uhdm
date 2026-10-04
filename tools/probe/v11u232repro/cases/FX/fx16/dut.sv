// § caCallArgTruncByBase232v
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
// a negative value through a narrower unsigned logic formal
module sub #(parameter int N = 0) (output int o);
  assign o = q::w2(N, 0);
endmodule
module top(output int o);
  sub #(.N(-3)) u (.o(o));
endmodule
