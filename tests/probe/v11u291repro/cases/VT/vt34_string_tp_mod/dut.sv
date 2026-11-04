// § tpUseSigBindsTpObj291
module child #(parameter type T = string) (output int o);
  T s;
  initial begin s = "ab"; o = s.len(); end
endmodule
module dut (output int o);
  child u (.o(o));
endmodule
