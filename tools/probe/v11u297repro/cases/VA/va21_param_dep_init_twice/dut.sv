// § varDeclInitElabSpan297
typedef struct packed { logic [1:0] a; logic b; } t_t;
module c_m #(parameter logic [2:0] V = 3'b001) (output logic [2:0] o);
  var t_t x = V;
  assign o = x;
endmodule
module dut(output logic [2:0] o, output logic [2:0] p);
  c_m #(.V(3'b110)) u1(.o(o));
  c_m u2(.o(p));
endmodule
