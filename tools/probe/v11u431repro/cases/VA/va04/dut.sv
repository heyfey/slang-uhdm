// § modParamArrElemDefRangeSym431 (a body localparam array)
module rom #(parameter int W = 4) ();
localparam bit [W-1:0] arr_p [1:0] = '{4'h1, 4'h2};
endmodule
module top; rom #(.W(4)) r(); endmodule
