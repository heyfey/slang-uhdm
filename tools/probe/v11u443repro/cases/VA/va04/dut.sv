// § elabProgMemberArrLoopVar443
module top; prg p(); endmodule
program prg;
int q[$]; int s;
initial begin q.push_back(1); foreach (q[i]) begin if (i > 0) s = q[i]; for (int k = 0; k < i; k++) s += k; end end
endprogram
