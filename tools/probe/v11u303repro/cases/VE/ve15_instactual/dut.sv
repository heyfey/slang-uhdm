// § genCaEnumQualWholeSpan303
package p;
  typedef enum logic [2:0] {OpA = 3'h0, OpB = 3'h4} op_e;
  function automatic logic [2:0] f(op_e x); return x; endfunction
endpackage
module sub (input logic [2:0] x, output logic [2:0] y); assign y = x; endmodule
module top(output logic [2:0] o [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    sub u (.x(p::OpB), .y(o[i]));
  end
endmodule
