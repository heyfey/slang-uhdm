// § elabProgMemberArrLoopVar443
class C #(int N = 2); int arr[N]; int s; function void f(); foreach (arr[i]) s = s + i; endfunction endclass
module top; prg p(); endmodule
program prg;
initial begin C #(3) h; h = new; h.f(); end
endprogram
