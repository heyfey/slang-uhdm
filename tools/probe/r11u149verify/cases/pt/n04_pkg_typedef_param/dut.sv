// § paramAliasBoundRefUnstored144
package p;
  parameter int X = 4;
  typedef logic [X-1:0] my_t;
endpackage
module dut(output logic [3:0] o);
  parameter p::my_t Y = 3;
  assign o = Y;
endmodule
