// § modStructMemberQualSpan214 — CRLF with tabs: a module struct member bound as a product of qualified names, spaced qualifiers
package cfg;
	localparam int W = 2;
	localparam int K = 3;
endpackage
module m(output logic [15:0] o);
	typedef struct packed {
		logic [cfg::W*cfg::K-1:0]	a;
		logic [ cfg::K : 0 ]	b;
	} s_t;
	s_t r;
	assign r = '1;
	assign o = 16'(r);
endmodule
module top(output logic [15:0] o);
	m u(.o(o));
endmodule
