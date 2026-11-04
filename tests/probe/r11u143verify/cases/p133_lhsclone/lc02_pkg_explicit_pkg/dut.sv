// § impPaLhsDisjointClone133
// case lc02: a package explicitly importing one parameter of another package and deriving its own
package base_p; parameter int BW = 5; parameter int BX = 1; endpackage
package der_p;
  import base_p::BW;
  localparam int DW = BW * 2;
endpackage
module top(output logic [9:0] o);
  assign o = der_p::DW;
endmodule
