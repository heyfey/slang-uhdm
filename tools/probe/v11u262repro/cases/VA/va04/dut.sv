// § genEnumVarLocatedConst262 (an interface's if-generate declaring the enum variable)
package ip;
  typedef enum logic [1:0] { E_A, E_B, E_C } e_t;
endpackage
interface ifc import ip::*; #(parameter bit P = 1) ();
  e_t t;
  logic o;
  if (P) begin : g
    e_t q;
    assign q = t;
    assign o = (q == E_C);
  end
endinterface
module top(output logic o);
  ifc i();
  assign o = i.o;
endmodule
