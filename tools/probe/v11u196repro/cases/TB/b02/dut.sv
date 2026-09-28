// § tpArrBoundAtLeftOperand196: a package-qualified leaf (control) and a package-qualified product on the left
package pk; parameter int N = 3; endpackage
module dut #(parameter type t_t = logic [1:0]) (output t_t o);
  t_t [pk::N-1:0] a;
  t_t [pk::N*2-1:0] b;
  assign o = a[0] ^ b[0];
endmodule
