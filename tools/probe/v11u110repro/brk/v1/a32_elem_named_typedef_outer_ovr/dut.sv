module child #(parameter type w_t = logic) (input logic [7:0] rt_i, output logic sel_o);
  typedef logic [1:0] e_t;
  localparam type rt_t = e_t [3:0];
  rt_t v;
  assign v = rt_i;
  assign sel_o = ^v;
endmodule
module mid #(parameter type e_t = logic) (input logic [7:0] a, output logic o);
  child u (.rt_i(a), .sel_o(o));
endmodule
module dut(input logic [7:0] a, output logic o);
  mid #(.e_t(logic [2:0])) m (.a(a), .o(o));
endmodule
