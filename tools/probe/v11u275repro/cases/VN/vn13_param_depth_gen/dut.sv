// § defNetTpPatKeepsActual275v — a parameter-dependent dimension, instance in a generate block
module child #(parameter type id_t = logic, parameter int N = 4, localparam type rt_t = id_t [N-1:0]) (input logic [15:0] r, output logic o);
  rt_t y;
  assign y = r;
  assign o = ^y;
endmodule
module dut (input logic [15:0] r, output logic o);
  if (1) begin : g
    child #(.id_t(logic [1:0]), .N(3)) u (.r(r), .o(o));
  end
endmodule
