// § clsQBoundUntypedParamTs410
class c;
  parameter signed S = 3;
  parameter [3:0] V = 2;
  parameter int I = 5;
  int a[$:S];
  int b[$:V];
  int d[$:I];
endclass
module top;
  c h;
endmodule
