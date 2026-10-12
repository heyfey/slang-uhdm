// § scopedSimpleTdMemberBindsListing305
package pk; typedef logic [2:0] w_t; endpackage
module dut import pk::*; #(parameter type T = struct packed { w_t a; logic b; }) (input T i, output T o);
  assign o = i;
endmodule
