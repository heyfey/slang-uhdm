package p0;
  typedef enum logic [3:0] { A = 4'h3, B = 4'h7 } e_t;
endpackage
package p1;
  import p0::*;
  parameter logic [1:0] C0 = 2'b01;
  parameter int X = { 28'h0, A };
endpackage
module dut (input logic [31:0] i, output logic o);
  import p1::*;
  assign o = (i == X);
endmodule
