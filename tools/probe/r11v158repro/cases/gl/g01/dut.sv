// § genCaLhsEnumConstClone158
module dut(input logic [7:0] a, output logic [3:0][7:0] o, output logic [3:0][7:0] q);
  typedef enum logic [1:0] {A, B, C, D} e_t;
  for (genvar i = 0; i < 1; i++) begin : g
    assign {o[A], q[B]} = {a, a};
    assign o[B][C] = a[0];
  end
endmodule
