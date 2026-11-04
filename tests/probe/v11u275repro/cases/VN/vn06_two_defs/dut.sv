// § defNetTpDimLastInstPat275 — two definitions interleaved
module ca #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (input logic [15:0] a, output logic [15:0] o);
  rt_t x;
  assign x = a;
  assign o = x;
endmodule
module cb #(parameter type id_t = logic, localparam type rt_t = id_t [1:0]) (input logic [15:0] a, output logic [15:0] o);
  rt_t x;
  assign x = a;
  assign o = x;
endmodule
module dut (input logic [15:0] a, output logic [15:0] o1, o2, o3);
  ca #(.id_t(logic [1:0])) u1 (.a(a), .o(o1));
  cb #(.id_t(logic [2:0])) u2 (.a(a), .o(o2));
  ca #(.id_t(logic [2:0])) u3 (.a(a), .o(o3));
endmodule
