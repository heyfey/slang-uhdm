// § tpUseSigBindsTpObj291
module child #(parameter type T = logic) (input T a, output logic o);
  T v;
  assign v = a;
  assign o = v[0];
endmodule
module dut (input int a, output logic o);
  child #(.T(int signed)) u (.a(a), .o(o));
endmodule
