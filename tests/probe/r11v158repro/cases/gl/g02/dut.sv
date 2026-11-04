// § genCaLhsEnumConstClone158
typedef struct packed { logic [3:0][7:0] f; } s_t;
module dut(input logic [7:0] a, output s_t s);
  typedef enum logic [1:0] {A, B, C, D} e_t;
  if (1) begin : g
    assign s.f[B] = a;
  end
endmodule
