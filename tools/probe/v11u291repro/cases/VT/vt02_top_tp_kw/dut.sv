// § tpUseSigBindsTpObj291
module dut #(parameter type T = logic [3:0]) (input T a, output logic o);
  T v;
  assign v = a;
  assign o = ^v;
endmodule
