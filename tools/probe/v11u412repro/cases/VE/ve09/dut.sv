// § enumRangedMemberSurelogVal412
package pk;
  typedef enum bit [3:0] {S0[2:3], S1 = 4'b1000, S2} e_t;
endpackage
module top(output pk::e_t o);
  assign o = pk::S2;
endmodule
