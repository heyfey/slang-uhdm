// § unsupportedTsInitEnd152
module mod_m;
	logic [31:0] a;
	covergroup cg(int lim);
	coverpoint a;
	endgroup
	cg cg_inst = new(3);
endmodule
