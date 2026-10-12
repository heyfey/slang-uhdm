// § genCaEnumQualWholeSpan303
package p;
  typedef enum logic [2:0] {OpA = 3'h0, OpB = 3'h4} op_e;
  function automatic logic [2:0] f(op_e x); return x; endfunction
endpackage
module top(input logic [7:0] v, input p::op_e s, output logic [2:0] o [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i] = v[p::OpB];
  end
endmodule
