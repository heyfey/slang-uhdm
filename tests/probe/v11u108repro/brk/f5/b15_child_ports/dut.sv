module child #(parameter type id_t = logic, localparam int D = 1 << $bits(id_t), localparam type rt_t = id_t [D-1:0]) (input rt_t rt_i, output rt_t rt_o);
  assign rt_o = rt_i;
endmodule
module dut (input logic [7:0] a, output logic [7:0] o, output logic [1:0] p);
  child #(.id_t(logic [1:0])) u (.rt_i(a), .rt_o(o));
  child v (.rt_i(a[1:0]), .rt_o(p));
endmodule
