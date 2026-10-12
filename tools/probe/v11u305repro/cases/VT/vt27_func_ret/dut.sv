// § scopedSimpleTdMemberBindsListing305
package pk; typedef logic [2:0] w_t; endpackage
module dut (output logic [2:0] o);
  typedef struct packed { pk::w_t a; logic b; } s_t;
  function automatic s_t mk(input logic [2:0] x); mk.a = x; mk.b = 1'b0; endfunction
  s_t v;
  assign v = mk(3'd3);
  assign o = v.a;
endmodule
