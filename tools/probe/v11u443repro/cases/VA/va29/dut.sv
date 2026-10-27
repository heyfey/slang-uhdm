// § elabProgMemberArrLoopVar443
module top; prg p(); endmodule
program prg;
int a[3];
int s;
initial begin
  foreach (a[i]) a[i] = i;
  foreach (a[j]) s = s + a[j] + j;
end
endprogram
