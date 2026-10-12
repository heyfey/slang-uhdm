// § scopedSimpleTdMemberBindsListing305
package pk; typedef logic [2:0] w_t; endpackage
module dut (output logic [3:0] o);
  typedef struct packed { pk::w_t a; logic b; } s_t;
  localparam s_t P = '{a: 3'd5, b: 1'b1};
  assign o = P;
endmodule
