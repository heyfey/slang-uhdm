package vp;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  logic en;
  logic [7:0] data;
  s_t st;
  logic [7:0] arr [4];
endpackage
module top (input logic [1:0] k, output logic [7:0] o);
  function automatic logic [7:0] f(input logic [7:0] x); return x << 1; endfunction
  assign o = f(vp::arr[k]) | f(vp::data);
endmodule
