// § scopedSimpleTdMemberBindsListing305
package pk; typedef logic [2:0] w_t; typedef logic [1:0] v_t; endpackage
module dut #(parameter type T = struct packed { pk::w_t a; pk::v_t b; }) (input T i, output T o);
  assign o = i;
endmodule
