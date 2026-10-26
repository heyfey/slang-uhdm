// § modParamArrElemDefRangeSym431 (a two-dimensional packed element)
module rom #(parameter int W = 2,
  parameter bit [1:0][W-1:0] arr_p [1:0] = '{4'h1, 4'h2}) ();
endmodule
module top; rom #(.W(2)) r(); endmodule
