// § scopedSimpleTdMemberBindsListing305
package pk; typedef logic [2:0] w_t; endpackage
package q;
  typedef struct packed { pk::w_t a; logic b; } s_t;
  function automatic logic [2:0] get(s_t s); return s.a; endfunction
endpackage
module dut (input q::s_t i, output logic [2:0] o);
  assign o = q::get(i);
endmodule
