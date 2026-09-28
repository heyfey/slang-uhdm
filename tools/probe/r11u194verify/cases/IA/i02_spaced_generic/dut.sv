// § ifaceArrPortSizeDimAtExpr183: interface-array ports with a spaced parenthesized size, a size written through a macro and a parameter expression, instanced twice
`define SZ 2
interface itf;
  logic a;
endinterface
module recv #(parameter int K = 1) (itf p[ (K+1) ], itf q[`SZ]);
endmodule
module top;
  itf a2[2] ();
  itf b2[2] ();
  itf c3[3] ();
  recv #(.K(1)) u1 (.p(a2), .q(b2));
  recv #(.K(2)) u2 (.p(c3), .q(b2));
endmodule
