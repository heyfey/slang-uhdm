// § tpUseSigBindsTpObj291
package pk; typedef logic [2:0] w_t; endpackage
module child #(parameter type T = logic) (input logic [2:0] a, output logic o);
  function automatic logic f(input logic [2:0] x);
    T t;
    t = x;
    return ^t;
  endfunction
  assign o = f(a);
endmodule
module dut (input logic [2:0] a, output logic o);
  child #(.T(pk::w_t)) u (.a(a), .o(o));
endmodule
