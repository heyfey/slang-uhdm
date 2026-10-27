// § elabProgMemberArrLoopVar443
typedef bit [3:0] idx_t;
module top; prg p(); endmodule
program prg;
int aa[idx_t]; int s;
initial begin aa[3] = 1; foreach (aa[k]) s = s + k; end
endprogram
