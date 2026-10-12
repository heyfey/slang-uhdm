// § tpUseBodyTdTargetAbstains291v
module child (input logic [3:0] a, output logic o);
  typedef logic [3:0] lt;
  localparam type A = lt;
  localparam type T = A;
  T v;
  assign v = a;
  assign o = ^v;
endmodule
module dut (input logic [3:0] a, output logic o);
  child u (.a(a), .o(o));
endmodule
