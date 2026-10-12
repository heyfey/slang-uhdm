// § genCaEnumQualWholeSpan303
package p;
  typedef enum logic [2:0] {OpA = 3'h0, OpB = 3'h4} op_e;
  function automatic logic [2:0] f(op_e x); return x; endfunction
endpackage
module top #(parameter int K = 1) (output logic [2:0] o);
  case (K)
    1: begin : g assign o = p::OpB; end
    default: begin : h assign o = p::OpA; end
  endcase
endmodule
