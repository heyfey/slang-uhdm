// § modParamArrElemDefRangeSym431 (a bound reading a $unit parameter, not a module one)
localparam UW = 4;
module rom #(parameter bit [UW-1:0] arr_p [1:0] = '{4'h1, 4'h2}) ();
endmodule
module top; rom r(); endmodule
