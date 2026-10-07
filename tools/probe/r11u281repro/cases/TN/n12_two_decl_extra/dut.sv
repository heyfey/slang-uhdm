// § defNetTpPatNestedSig281
module child #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (input logic [15:0] a, output logic o);
  rt_t [1:0] x, y;
  assign x = {a, a};
  assign y = {a, a};
  assign o = ^x ^ ^y;
endmodule
module dut(input logic [15:0] a, output logic o);
  child #(.id_t(logic [1:0])) u (.a(a), .o(o));
endmodule
