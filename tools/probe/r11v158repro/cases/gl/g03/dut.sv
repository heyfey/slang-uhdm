// § genCaLhsEnumConstClone158
module sub #(parameter int N = 1) (input logic [7:0] a, output logic [3:0][7:0] o);
  typedef enum logic [1:0] {A, B, C, D} e_t;
  for (genvar i = 0; i < N; i++) begin : g
    assign o[C] = a;
  end
endmodule
module dut(input logic [7:0] a, output logic [3:0][7:0] o, output logic [3:0][7:0] q);
  sub #(.N(1)) u(.a(a), .o(o));
  sub #(.N(2)) v(.a(a), .o(q));
endmodule
