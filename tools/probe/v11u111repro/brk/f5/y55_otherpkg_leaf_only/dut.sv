package p0;
  parameter logic [3:0] C0 = 4'h9;
  parameter logic [3:0] C1 = 4'h6;
endpackage
package p1;
  import p0::*;
  parameter logic [7:0] X = { C0, C1 };
endpackage
module dut (input logic [7:0] i, output logic o);
  import p1::*;
  assign o = (i == X);
endmodule
