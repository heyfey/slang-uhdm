// § elabProgMemberArrLoopVar443
module top; prg p(); endmodule
program prg;
class C; int arr[3]; int s; function void f(); foreach (arr[i]) s = s + i; endfunction endclass
int a[2];
initial begin C h; h = new; foreach (a[i]) a[i] = i; h.f(); end
endprogram
