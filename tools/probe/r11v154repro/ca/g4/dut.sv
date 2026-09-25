// § elabCastSharesDeclRef154
package p; localparam int W = 3; endpackage
module dut (input logic x, output logic [3:0] o);
  assign o = x ? p::W'(1) : p::W'(2);
endmodule
