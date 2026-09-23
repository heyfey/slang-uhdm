package p0;
  parameter logic [1:0] C0 = 2'h2;
endpackage
package p1;
  import p0::*;
  typedef enum logic [3:0] { A = 4'h3, B = 4'h7 } e_t;
  parameter logic [1:0] D0 = 2'h1;
  parameter logic [7:0] X = { C0, D0, A };
endpackage
module dut (input logic [7:0] i, output logic o);
  import p1::*;
  assign o = (i == X);
endmodule
