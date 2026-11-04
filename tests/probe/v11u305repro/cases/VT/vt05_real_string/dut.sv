// § scopedSimpleTdMemberBindsListing305
package pk; typedef real r_t; typedef string st_t; endpackage
module dut (output logic o);
  typedef struct { pk::r_t r; pk::st_t s; logic b; } s_t;
  s_t x;
  assign o = x.b;
endmodule
