// § tpUseSigBindsTpObj291
package pk; typedef logic [2:0] w_t; endpackage
module child #(parameter type T = logic) (output logic o);
  T v1 = 3'd1, v2 = 3'd2;
  assign o = ^(v1 ^ v2);
endmodule
module dut (output logic o);
  child #(.T(pk::w_t)) u (.o(o));
endmodule
