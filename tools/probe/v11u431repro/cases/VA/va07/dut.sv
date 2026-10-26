// § modParamArrElemDefRangeSym431 (a package parameter in the bound)
package pk; localparam PW = 4; endpackage
module rom #(parameter bit [pk::PW-1:0] arr_p [1:0] = '{4'h1, 4'h2}) ();
endmodule
module top; rom r(); endmodule
