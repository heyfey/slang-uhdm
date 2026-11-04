// § ndaRangeQueryFold216 — a package-qualified parameter bound pkg::W-1
package pk;
  parameter int W = 6;
endpackage
module dut (input logic [pk::W-1:0] i, output logic [7:0] o);
  wire [7:0] w = $high(i);
  assign o = w;
endmodule
