module child #(parameter type id_t = logic [1:0], localparam type rt_t = id_t [3:0]) (input rt_t x [2], output logic [7:0] o);
  assign o = x[1];
endmodule
module dut(input logic [7:0] a, output logic [7:0] o);
  logic [7:0] q [2];
  assign q[0] = a;
  assign q[1] = a;
  child u (.x(q), .o(o));
endmodule
