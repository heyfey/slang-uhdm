package p0;
  parameter logic [3:0] C0 = 4'h9;
endpackage
package p1;
  import p0::C0;
  typedef enum logic [3:0] { A = 4'h3, B = 4'h7 } e_t;
  parameter logic [7:0] X = { C0, A };
endpackage
module dut (input logic [7:0] i, output logic o);
  import p1::*;
  assign o = (i == X);
endmodule
