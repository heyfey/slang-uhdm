// § unitVarRefMintsNet418
int cnt = 3;
module top;
  int x;
  initial begin
    for (int i = 0; i < cnt; i++) x += i;
    cnt = 4;
  end
endmodule
