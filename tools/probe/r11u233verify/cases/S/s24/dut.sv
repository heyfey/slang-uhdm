// § parseViewSizeExprEval228 § pvSizeNoElemDeclines228v — a class-handle array and a virtual-interface-free packed union
module dut (output logic [7:0] o1, o2, o3);
  typedef union packed { logic [7:0] a; logic [3:0][1:0] b; } u_t;
  u_t ua [3];
  u_t us;
  wire [7:0] w1 = $size(ua);
  assign o1 = w1;
  wire [7:0] w2 = $size(ua, 2);
  assign o2 = w2;
  wire [7:0] w3 = $size(us);
  assign o3 = w3;
endmodule
