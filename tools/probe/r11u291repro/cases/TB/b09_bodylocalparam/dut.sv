// § tpUseSigBindsTpObj291
package pk; typedef logic [2:0] w_t; endpackage
module dut (input logic [2:0] a, output logic o);
  localparam type T = pk::w_t;
  T v;
  assign v = a;
  assign o = ^v;
endmodule
