package q;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
module sub #(parameter q::e_t M = q::A) (output logic [1:0] o);
  assign o = M;
endmodule
module dut (output logic [1:0] o);
  sub #(.M(q::C)) u (.o(o));
endmodule
