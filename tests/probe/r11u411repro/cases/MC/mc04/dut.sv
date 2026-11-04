// § callResultMemberDropped411
package pk;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } st_t;
  function automatic st_t mk(input logic [3:0] x);
    mk.a = x; mk.b = ~x;
  endfunction
endpackage
module top(input logic [3:0] x, output logic [3:0] r);
  assign r = pk::mk(x).a;
endmodule
