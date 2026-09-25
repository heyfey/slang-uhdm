// § paramAliasBoundRefUnstored144
interface ifc;
  parameter int X = 4;
  typedef logic [X-1:0] my_t;
  parameter my_t Y = 3;
  logic [X-1:0] v;
  assign v = Y;
endinterface
module dut(output logic [3:0] o);
  ifc u();
  assign o = u.v;
endmodule
