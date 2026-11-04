// § elabProgMemberArrLoopVar443
module top;
logic [7:0] v;
initial foreach (v[i]) v[i] = 1'b0;
endmodule
