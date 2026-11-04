// § defNetTypedefEndWrite134
module top(input logic c, output logic o);
  typedef struct packed { logic [1:0] a; logic b; } s_t;
  for (genvar g = 0; g < 2; g++) begin : gb
    s_t q [2];
    assign q[0] = {c, c, c};
  end
  assign o = gb[0].q[0].b;
endmodule
