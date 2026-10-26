// § modParamArrElemDefRangeSym431 (a bound reading two parameters)
module rom #(parameter int W = 2, parameter int D = 2,
  parameter bit [W*D-1:0] arr_p [1:0] = '{4'h1, 4'h2}) ();
endmodule
module top; rom #(.W(2)) r(); endmodule
