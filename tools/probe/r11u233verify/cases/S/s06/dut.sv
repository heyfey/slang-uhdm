// § parseViewSizeExprEval228 § pvSizeNoElemDeclines228v — a fixed-fixed-queue operand (logic [3:0] fq [2][3][$]) beside a plain fixed operand
module dut (output logic [7:0] o1, o2, o3);
  logic [3:0] fq [2][3][$];
  logic [3:0] ff [5];
  wire [7:0] w1 = $size(fq);
  assign o1 = w1;
  wire [7:0] w2 = $size(fq, 2);
  assign o2 = w2;
  wire [7:0] w3 = $size(ff);
  assign o3 = w3;
endmodule
