// § modParamArrElemDefRangeSym431 (an instance with defaults only)
module rom #(parameter int W = 4,
  parameter bit [W-1:0] arr_p [1:0] = '{4'h1, 4'h2}) ();
endmodule
module top; rom r(); endmodule
