// § paramInitSysArgBitSelAtIndex421
package pk; parameter bit [3:0][3:0] P = 'h1234; localparam W = $bits(P[1]); endpackage
module top (output logic [3:0] o);
  assign o = pk::W;
endmodule
