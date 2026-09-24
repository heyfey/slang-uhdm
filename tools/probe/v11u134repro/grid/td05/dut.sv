// § defNetTypedefArrayShares134
module top(input logic c, output logic o);
  typedef struct packed { logic [1:0] a; logic b; } s_t;
  wire s_t w [2];
  assign w[0] = {c, c, c};
  assign w[1] = {c, 2'b00};
  assign o = w[0].b ^ w[1].a[1];
endmodule
