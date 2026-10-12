// § scopedSimpleTdMemberBindsListing305
package pk; typedef logic [2:0] w_t; endpackage
package pc;
  class C;
    typedef struct packed { pk::w_t a; logic b; } s_t;
    s_t x;
  endclass
endpackage
module dut (output logic o);
  pc::C c;
  assign o = 1'b0;
endmodule
