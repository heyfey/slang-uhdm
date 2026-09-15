typedef struct packed { logic [3:0] op; } d_t;
module m_e3 (input logic [7:0] a, input logic [4:0] b, output logic [12:0] o);
  c_e3 #(.dtype(logic [$bits(a) + $bits(b) - 1:0])) u (.d_i(o), .d_o(o));
endmodule
module c_e3 #(parameter type dtype = d_t) (input dtype d_i, output dtype d_o);
  assign d_o = d_i;
endmodule
module tb_e3; logic [12:0] o; m_e3 t(.a(8'd0),.b(5'd0),.o(o)); endmodule
