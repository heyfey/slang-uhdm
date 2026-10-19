// § enumRangedMemberSurelogVal412
package pk;
  typedef enum {K[1:2], L} k_e;
endpackage
module top();
	pk::k_e k;
	initial k = pk::L;
endmodule
