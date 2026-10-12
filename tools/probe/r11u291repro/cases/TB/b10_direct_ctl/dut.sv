// § tpUseSigBindsTpObj291
package pk; typedef logic [2:0] w_t; endpackage
module child (input pk::w_t a, output logic o);
  pk::w_t v;
  assign v = a;
  assign o = ^v;
endmodule
module dut (input logic [2:0] a, output logic o);
  child u (.a(a), .o(o));
endmodule
