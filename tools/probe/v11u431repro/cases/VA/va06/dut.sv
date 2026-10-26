// § modParamArrElemDefRangeSym431 (an interface)
interface rom #(parameter int W = 4,
  parameter bit [W-1:0] arr_p [1:0] = '{4'h1, 4'h2}) ();
endinterface
module top; rom #(.W(4)) r(); endmodule
