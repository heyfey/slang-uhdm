package q;
  typedef struct packed { logic [1:0] a; logic b; } s_t;
endpackage
module sub #(parameter q::s_t M = '0) (output logic [2:0] o);
  assign o = M;
endmodule
module dut (output logic [2:0] o);
  sub #(.M(3'b101)) u (.o(o));
endmodule
