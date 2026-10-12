// § scopedSimpleTdMemberBindsListing305
package pk; typedef logic [2:0] w_t; endpackage
package pk2; typedef logic [4:0] w_t; endpackage
module dut (output logic [7:0] o);
  typedef struct packed { pk::w_t a; pk2::w_t b; } s_t;
  s_t x;
  assign x = 8'h5a;
  assign o = x;
endmodule
