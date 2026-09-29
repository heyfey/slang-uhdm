// § parseViewSizeExprEval228 § pvSizeNoElemDeclines228v — a typedef'd unpacked array and a typedef'd packed 2-D vector
module dut (output logic [7:0] o1, o2, o3);
  typedef logic [3:0] arr_t [5];
  typedef logic [3:0][1:0] pk_t;
  arr_t a;
  pk_t b;
  wire [7:0] w1 = $size(a);
  assign o1 = w1;
  wire [7:0] w2 = $size(b);
  assign o2 = w2;
  wire [7:0] w3 = $size(b, 2);
  assign o3 = w3;
endmodule
