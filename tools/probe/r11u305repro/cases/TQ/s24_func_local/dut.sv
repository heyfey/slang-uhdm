// § scopedSimpleTdMemberBindsListing305
package pk; typedef logic [2:0] w_t; endpackage
module dut (input logic [3:0] i, output logic [3:0] o);
  function automatic logic [3:0] f(input logic [3:0] v);
    typedef struct packed { pk::w_t a; logic b; } s_t;
    s_t x;
    x = v;
    return x;
  endfunction
  assign o = f(i);
endmodule
