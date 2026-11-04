// § defNetTpPatNestedSig281
module child #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (input logic [15:0] a, output logic [15:0] o);
  rt_t x [2];
  rt_t [1:0] y;
  rt_t z;
  assign x[0] = a; assign x[1] = a;
  assign y = a;
  assign z = a;
  assign o = y ^ x[0] ^ z;
endmodule
module dut(input logic [15:0] a, output logic [15:0] o);
  child #(.id_t(logic [1:0])) u (.a(a), .o(o));
endmodule
