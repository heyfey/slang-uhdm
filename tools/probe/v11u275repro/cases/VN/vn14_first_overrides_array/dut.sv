// § defNetTpPatKeepsActual275v — a parameter-bound dimension, the first instance overriding the array itself
module child #(parameter type id_t = logic, parameter int N = 4, parameter type rt_t = id_t [N-1:0]) (input logic [15:0] r, output logic o);
  rt_t y;
  assign y = r;
  assign o = ^y;
endmodule
module dut (input logic [15:0] r, output logic o1, o2, o3);
  child #(.rt_t(logic [5:0])) u (.r(r), .o(o1));
  child #(.id_t(logic [1:0]), .N(3)) w (.r(r), .o(o2));
  child #(.id_t(logic [2:0]), .N(2)) x (.r(r), .o(o3));
endmodule
