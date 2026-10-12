// § genCaEnumQualWholeSpan303
package p;
  typedef enum logic [2:0] {OpA = 3'h0, OpB = 3'h4} op_e;
  function automatic logic [2:0] f(op_e x); return x; endfunction
endpackage
interface ifc;
  logic [2:0] v [2];
  for (genvar i = 0; i < 2; i++) begin : g
    assign v[i] = p::OpB;
  end
endinterface
module top(output logic [2:0] o);
  ifc u ();
  assign o = u.v[0];
endmodule
