// § ifaceArrPortSizeDimAtExpr183: interface-array ports with size dimensions written as a localparam, a package parameter and a two-dimensional size, beside a range form
package pk;
  parameter int N = 2;
endpackage
interface itf;
  logic a;
  modport mp (input a);
endinterface
module recv #(parameter int M = 3) (itf.mp p[M], itf q[pk::N], itf r[1:0], itf.mp s[2][2]);
  localparam int L = 2;
endmodule
module top;
  itf a3[3] ();
  itf a2[2] ();
  itf b2[1:0] ();
  itf c22[2][2] ();
  recv #(.M(3)) u (.p(a3), .q(a2), .r(b2), .s(c22));
endmodule
