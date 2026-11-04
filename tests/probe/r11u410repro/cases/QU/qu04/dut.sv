// § clsQBoundUntypedParamTs410
class c;
  parameter P = 3, Q = 7;
  int a[$:P];
  int b[$:Q][2];
endclass
module top;
  c h;
endmodule
