package p0;
  parameter logic [3:0] C0 = 4'h9;
  typedef enum logic [3:0] { A = 4'h3, B = 4'h7 } e_t;
endpackage
package p1;
  import p0::*;
  parameter logic [7:0] X = { C0, B };
endpackage
module dut (input logic [7:0] i, output logic o);
  import p1::*;
  assign o = (i == X);
endmodule
