// § unitVarRefMintsNet418
int cnt = 3;
module top;
  int x;
  initial x = $unit::cnt + 1;
endmodule
