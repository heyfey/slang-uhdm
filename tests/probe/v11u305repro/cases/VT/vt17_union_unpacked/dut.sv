// § scopedSimpleTdMemberBindsListing305
package pk; typedef logic [2:0] w_t; endpackage
module dut (output logic [2:0] o);
  typedef union { pk::w_t a; logic [7:0] b; } u_t;
  u_t x;
  assign o = x.a;
endmodule
