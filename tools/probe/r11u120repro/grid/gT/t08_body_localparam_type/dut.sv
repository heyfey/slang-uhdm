module child #(parameter type T = logic) (input T [3:0] a, output logic [3:0] b);
  localparam type e_t = T;
  e_t [3:0] tmp;
  assign tmp = a;
  assign b = {tmp[3][0], tmp[2][0], tmp[1][0], tmp[0][0]};
endmodule
module dut (input logic [11:0] a, output logic [3:0] b);
  child #(.T(logic [2:0])) u (.a(a), .b(b));
endmodule
