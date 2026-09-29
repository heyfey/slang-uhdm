// § tfArgScalarTdWriter223
package p;
  typedef bit [7:0] B8;
endpackage
module sub #(parameter int K = 1) (input logic [7:0] a, output logic [7:0] o);
  import p::*;
  function automatic B8 add(B8 x);
    return x + B8'(K);
  endfunction
  assign o = add(a);
endmodule
module top (input logic [7:0] a, output logic [7:0] o1, o2);
  sub #(1) u1 (.a(a), .o(o1));
  sub #(2) u2 (.a(a), .o(o2));
endmodule
