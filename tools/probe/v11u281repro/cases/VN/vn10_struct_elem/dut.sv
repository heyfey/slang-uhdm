// § defNetTpPatNestedSig281
typedef struct packed { logic a; logic b; } s_t;
module child #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (input logic [7:0] a, output logic [7:0] o);
  rt_t x [2];
  assign x[0] = a; assign x[1] = a;
  assign o = x[1];
endmodule
module dut(input logic [7:0] a, output logic [7:0] o);
  child #(.id_t(s_t)) u (.a(a), .o(o));
endmodule
