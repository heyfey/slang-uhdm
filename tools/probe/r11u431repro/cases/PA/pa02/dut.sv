// § modParamArrElemDefRangeSym431
module rom #(parameter int els_p = 1
  ,parameter int width_p = 1
  ,parameter bit [width_p-1:0] arr_p [els_p-1:0] = '{default:0}
  ) ();
endmodule
module top;
rom r();
endmodule
