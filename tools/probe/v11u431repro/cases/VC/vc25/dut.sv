// § connOpGenvarAbstain431v
module child(input [7:0] a, output b);
assign b = a[0];
endmodule
typedef struct packed { logic [31:0] d; logic [7:0] s; } pk_t;
module sub(input pk_t p, output [1:0] w);
localparam W = 4;
for (genvar i = 0; i < 2; i++) begin : g
  child c(.a(p.s[i +: W - i]), .b(w[i]));
end
endmodule
module top(input pk_t p, output [1:0] w); sub u(.p(p), .w(w)); endmodule
