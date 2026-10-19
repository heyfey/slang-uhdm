// § callResultMemberDropped411
module top(output int r);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } st_t;
  function automatic st_t mk(input logic [3:0] x);
    mk.a = x; mk.b = ~x;
  endfunction
  assign r = mk(4'd3).b;
endmodule
