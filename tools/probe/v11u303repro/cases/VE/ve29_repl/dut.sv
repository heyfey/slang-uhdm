// § genCaEnumQualWholeSpan303
package p;
  typedef enum logic [2:0] {OpA = 3'h0, OpB = 3'h4} op_e;
endpackage
module top(input logic [7:0] v, input logic [7:0] m [8], input p::op_e s, output logic [7:0] o [2], output logic [7:0] q [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i] = {p::OpB{1'b1}};
  end
endmodule
