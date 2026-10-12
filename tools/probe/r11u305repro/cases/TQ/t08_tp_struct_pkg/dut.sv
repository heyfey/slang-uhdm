// § scopedSimpleTdMemberBindsListing305
package pk; typedef struct packed { logic [2:0] f; } w_t; endpackage
module dut #(parameter type T = struct packed { pk::w_t a; logic b; }) (input T i, output T o);
  assign o = i;
endmodule
