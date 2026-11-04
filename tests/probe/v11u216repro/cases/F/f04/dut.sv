// § ndaSizeQueryFold216 — $size of a packed struct variable and of an integer variable in net initializers
module dut (output logic [7:0] o, output logic [7:0] o2);
  typedef struct packed { logic [2:0] a; logic [4:0] b; } s_t;
  s_t sv;
  integer iv;
  wire [7:0] w = $size(sv);
  wire [7:0] w2 = $size(iv);
  assign o = w;
  assign o2 = w2;
endmodule
