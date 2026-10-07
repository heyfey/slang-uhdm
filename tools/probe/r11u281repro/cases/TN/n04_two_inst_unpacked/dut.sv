// § defNetTpPatNestedSig281
module child #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (input logic [15:0] a, output logic [15:0] o);
  rt_t x [2];
  assign x[0] = a[7:0];
  assign x[1] = a[15:8];
  assign o = {x[1], x[0]};
endmodule
module dut(input logic [15:0] a, output logic [15:0] o, output logic [15:0] p);
  child #(.id_t(logic [1:0])) u (.a(a), .o(o));
  child #(.id_t(logic [3:0])) v (.a(a), .o(p));
endmodule
