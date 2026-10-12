// § tpUseSigBindsTpObj291
module child #(parameter int W = 3) (input logic [2:0] a, output logic o);
  typedef logic [W-1:0] lt;
  T_holder #(.T(lt)) h (.a(a), .o(o));
endmodule
module T_holder #(parameter type T = logic) (input logic [2:0] a, output logic o);
  T v;
  assign v = a;
  assign o = ^v;
endmodule
module dut (input logic [2:0] a, output logic o);
  child u (.a(a), .o(o));
endmodule
