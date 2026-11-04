// § ovPatOpCopyAtLocalRef163v
typedef struct packed { logic [1:0] a; logic [2:0] b; } r_t;
module test #(parameter P = '0)(output logic [4:0] o); assign o = P; endmodule
module dut(output logic [4:0] o);
  localparam r_t L = '{a: 2'b10, b: 3'd5};
  test #(L) t(.o(o));
endmodule
