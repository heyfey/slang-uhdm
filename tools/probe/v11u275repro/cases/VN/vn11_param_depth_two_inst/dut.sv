// § defNetTpPatKeepsActual275v — a parameter-dependent dimension in two instances
module child #(parameter type id_t = logic, localparam int D = (1 << $bits(id_t)), localparam type rt_t = id_t [D-1:0]) (input logic [15:0] r, output logic o);
  rt_t y;
  assign y = r;
  assign o = ^y;
endmodule
module dut (input logic [15:0] r, output logic o1, o2);
  child #(.id_t(logic [1:0])) u (.r(r), .o(o1));
  child #(.id_t(logic)) w (.r(r), .o(o2));
endmodule
