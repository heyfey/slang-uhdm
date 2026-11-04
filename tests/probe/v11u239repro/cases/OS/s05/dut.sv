// § genConnOpSelIdxScope239
// an if-generate with a net index and an enum-constant index, the bank as in Earlgrey
package p;
  typedef enum logic [1:0] {B0, B1, B2, B3} bank_e;
endpackage
module sub (input logic a_i, input logic b_i, output logic o);
  assign o = a_i ^ b_i;
endmodule
module top import p::*; #(parameter bit EN = 1) (input logic r, input logic [1:0] bank, input logic [3:0] v, output logic [1:0] o);
  if (EN) begin : gen_e
    sub u_s (.a_i(r && v[bank]), .b_i(!v[B2]), .o(o[0]));
  end
  assign o[1] = r;
endmodule
