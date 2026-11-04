// § modImpTdParamTsClone409
module child #(parameter type T = bit) ();
endmodule
module top;
  typedef bit [3:0] ft_t;
  parameter ft_t A = 3;
  child #(.T(ft_t)) u();
endmodule
