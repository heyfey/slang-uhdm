package pk;
  typedef logic [2:0] w_t;
endpackage
module child #(parameter type T = logic, localparam int B = $bits(T)) (input logic [B-1:0] a, output logic [B-1:0] o);
  T r;
  assign r = a;
  assign o = r;
endmodule
module dut (input logic [5:0] a, output logic [5:0] o);
  child #(.T(pk::w_t [1:0])) u (.a(a), .o(o));
endmodule
