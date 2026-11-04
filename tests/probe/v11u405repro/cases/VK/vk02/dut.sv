// § bitsParamArgNoFold405
package p; parameter logic [6:0] K = 3; endpackage
module top (output logic [31:0] o);
  localparam lg = $bits(p::K);
  assign o = lg;
endmodule
