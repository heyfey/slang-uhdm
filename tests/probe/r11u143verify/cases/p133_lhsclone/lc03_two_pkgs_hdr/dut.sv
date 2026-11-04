// § impPaLhsDisjointClone133
// case lc03: two packages wildcard-imported in the module header, both read by the parameter port list
package pa_p; parameter int AW = 4; endpackage
package pb_p; parameter logic [3:0] BV = 4'h9; endpackage
module sub import pa_p::*, pb_p::*; #(parameter int W = AW, parameter logic [3:0] V = BV) (output logic [W-1:0] o);
  assign o = V;
endmodule
module top(output logic [3:0] o); sub u(.o(o)); endmodule
