// § caCallArgTruncByBase232v
// sized hex and sized decimal values wider than a narrower logic formal, in two instances
package q;
  function automatic int unsigned w8(logic [7:0] x);
    return x + 1;
  endfunction
endpackage
module sub #(parameter logic [15:0] N = 0) (output int o);
  assign o = q::w8(N);
endmodule
module top(output int o, output int p);
  sub #(.N(16'hABCD)) u (.o(o));
  sub #(.N(16'd700)) v (.o(p));
endmodule
