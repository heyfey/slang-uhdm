// § modParamArrElemDefRangeSym431 (a lower bound reading the parameter)
module rom #(parameter int W = 4,
  parameter bit [W:1] arr_p [2] = '{4'h1, 4'h2}) ();
endmodule
module top; rom #(.W(4)) r(); endmodule
