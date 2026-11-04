// § genCaEnumQualWholeSpan303
package p;
  typedef enum logic [2:0] {OpA = 3'h0, OpB = 3'h4} op_e;
  function automatic logic [2:0] f(op_e x); return x; endfunction
endpackage
module top(output logic [2:0] o [2][2]);
  for (genvar i = 0; i < 2; i++) begin : g
    for (genvar j = 0; j < 2; j++) begin : h
      assign o[i][j] = p::OpB;
    end
  end
endmodule
