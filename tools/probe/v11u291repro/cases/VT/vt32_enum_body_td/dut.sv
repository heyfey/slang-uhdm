// § tpUseBodyTdTargetAbstains291v
module child (input logic [1:0] a, output logic o);
  typedef enum logic [1:0] {A, B} e_t;
  localparam type T = e_t;
  T v;
  assign v = e_t'(a);
  assign o = (v == B);
endmodule
module dut (input logic [1:0] a, output logic o);
  child u (.a(a), .o(o));
endmodule
