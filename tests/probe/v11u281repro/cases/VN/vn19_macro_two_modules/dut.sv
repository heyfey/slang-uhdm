// § defNetTpPatNestedSig281
`define MK(name) module name #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (input logic [7:0] a, output logic [7:0] o); rt_t x [2]; assign x[0] = a; assign x[1] = a; assign o = x[1]; endmodule
`MK(c1)
`MK(c2)
module dut(input logic [7:0] a, output logic [7:0] o, output logic [7:0] p);
  c1 #(.id_t(logic [1:0])) u (.a(a), .o(o));
  c2 #(.id_t(bit [1:0])) v (.a(a), .o(p));
endmodule
