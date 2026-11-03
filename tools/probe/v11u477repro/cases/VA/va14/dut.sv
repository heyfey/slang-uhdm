// § caAddLeafIntMint477
package p;
  parameter logic [3:0] A = 4'd3;
endpackage
module top(output logic [3:0] z);
  assign z = p::A + 4'd1;
endmodule
