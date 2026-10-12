// § castPatTagKeyLocThroughParens302
// c08: inside a function body and a process
typedef struct packed { logic [7:0] n; logic [7:0] h; } cfg_t;
module dut (input logic [7:0] a, output cfg_t o);
  function automatic cfg_t f(input logic [7:0] x);
    return cfg_t'('{n: x, h: 8'h1});
  endfunction
  always_comb o = f(a);
endmodule
