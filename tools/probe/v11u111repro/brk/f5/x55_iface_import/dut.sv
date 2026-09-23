package p1;
  typedef enum logic [3:0] { A = 4'h3, B = 4'h7 } e_t;
  parameter logic [7:0] X = { 4'h1, A };
endpackage
interface ifc;
  import p1::*;
  logic [7:0] d;
  assign d = X;
endinterface
module dut (output logic [7:0] o);
  ifc u ();
  assign o = u.d;
endmodule
