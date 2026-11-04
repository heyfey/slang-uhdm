// § scopedSimpleTdMemberBindsListing305
package pk; typedef logic [2:0] w_t; endpackage
module sub #(parameter type T = struct packed { pk::w_t a; logic b; }) (input T i, output T o);
  assign o = i;
endmodule
module dut (input logic [3:0] i, output logic [3:0] o);
  sub u (.i(i), .o(o));
endmodule
