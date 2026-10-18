// § taggedVoidMemberTs402
module top();
typedef union tagged {
	void Invalid;
	int Valid;
} u_int;
u_int a, b;
endmodule
