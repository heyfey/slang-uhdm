// § tpUseBodyTdTargetAbstains291v
module child #(parameter int W = 4) (input logic [3:0] a, output logic o);
  typedef logic [W-1:0] lt;
  localparam type T = lt;
  T v;
  assign v = a;
  assign o = ^v;
endmodule
module dut (input logic [3:0] a, output logic o);
  child u (.a(a), .o(o));
endmodule
