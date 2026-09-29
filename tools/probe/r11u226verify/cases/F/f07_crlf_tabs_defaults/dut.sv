// § tfArgScalarTdWriter223 — CRLF with tabs: formals with defaults, output and ref directions, two formals on one line, a formal on its own line
package p;
	typedef shortint S_T;
	typedef byte	B_T;
	class c;
		task t(input S_T a = 3,	output B_T b,
			ref S_T r,
			B_T	last);
			b = B_T'(a);
		endtask
	endclass
endpackage
module top;
	import p::*;
endmodule
