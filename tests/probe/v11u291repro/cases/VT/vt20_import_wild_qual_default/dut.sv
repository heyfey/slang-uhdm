// § tpUseSigBindsTpObj291
package pk; typedef logic [2:0] w_t; endpackage
module child import pk::*; #(parameter type T = pk::w_t) (input T a, output logic o);
  T v;
  w_t z;
  assign v = a;
  assign z = a;
  assign o = ^(v ^ z);
endmodule
module dut (input logic [2:0] a, output logic o);
  child u (.a(a), .o(o));
endmodule
