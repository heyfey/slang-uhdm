// § scopedSimpleTdMemberBindsListing305
package pk; typedef logic [2:0] w_t; endpackage
module dut #(parameter type T = pk::w_t) (input T i, output T o);
  assign o = i;
endmodule
