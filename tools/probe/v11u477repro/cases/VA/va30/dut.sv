// § caAddLeafIntMint477
package p;
  parameter logic [7:0] P = 8'h21;
  function automatic logic [7:0] f(); return P + 8'd1; endfunction
endpackage
module top(output logic [7:0] z);
  assign z = p::f();
endmodule
