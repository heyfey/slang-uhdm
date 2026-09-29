// § ppIdentEndInRebuiltText219 § ppDotNameAfterArgToken219 — CRLF and tabs: a method-call actual forwarded through two multi-line macros
`define IN2(CB,M) \
	begin \
		CB.M; \
	end
`define OUT2(CB,M) \
	begin \
		`IN2(CB,M) \
	end
package p;
class cb_c;
	function void state_chg(int a, int b); endfunction
endclass
class user_c;
	cb_c cb;
	function void run(int x);
		`OUT2(cb, state_chg(x, 2))
	endfunction
endclass
endpackage
module top;
	import p::*;
endmodule
