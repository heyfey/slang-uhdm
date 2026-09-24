package p0;
  typedef enum logic [3:0] { A = 4'h3, B = 4'h7 } e_t;
endpackage
package p1;
  import p0::*;
  parameter logic [1:0] C0 = 2'b01;
  parameter logic [7:0] X = { 6'h0, {C0} };
endpackage
module dut (input logic [7:0] i, output logic o);
  import p1::*;
  assign o = (i == X);
endmodule
