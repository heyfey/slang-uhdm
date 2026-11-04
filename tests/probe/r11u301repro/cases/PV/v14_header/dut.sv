// § unitTdPureProtoFormalWriter301
`include "h.svh"
module dut (output int o);
  function s_t g(s_t y); return y; endfunction
  s_t r;
  initial begin r = g(r); o = r.a; end
endmodule
