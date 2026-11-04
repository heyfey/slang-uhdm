// § impPaLhsDisjointClone133 + § elabCloneFullNameUnstored137 (cross-ground pair, judged in --elabuhdm too)
// case x04: a header-import module with a parameter port list and a function reading the imported parameter
package hp; parameter int HW = 4; endpackage
module sub import hp::*; #(parameter int W = HW) (input logic [W-1:0] a, output logic [W-1:0] y);
  function automatic logic [W-1:0] f(input logic [W-1:0] v); return v ^ HW; endfunction
  always_comb y = f(a);
endmodule
module dut(input logic [3:0] a, output logic [3:0] y); sub u(.a(a), .y(y)); endmodule
