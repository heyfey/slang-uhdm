// § defNetTpPatKeepsActual275v — a parameter-bound dimension, the first instance nested one level down
module child #(parameter type id_t = logic, parameter int N = 4, localparam type rt_t = id_t [N-1:0]) (input logic [15:0] r, output logic o);
  rt_t y;
  assign y = r;
  assign o = ^y;
endmodule
module mid (input logic [15:0] r, output logic o);
  child #(.id_t(logic [2:0]), .N(2)) c (.r(r), .o(o));
endmodule
module dut (input logic [15:0] r, output logic o1, o2);
  mid m (.r(r), .o(o1));
  child #(.id_t(logic [1:0]), .N(3)) w (.r(r), .o(o2));
endmodule
