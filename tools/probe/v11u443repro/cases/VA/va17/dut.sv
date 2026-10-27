// § elabProgMemberArrLoopVar443
typedef string key_t;
module top; prg p(); endmodule
program prg;
int aa[key_t]; string s;
initial begin aa["x"] = 2; foreach (aa[k]) s = k; end
endprogram
