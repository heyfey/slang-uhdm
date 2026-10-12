// § tpUseSigBindsTpObj291
package pk; typedef logic [2:0] w_t; endpackage
module child #(parameter type T = logic, parameter bit EN = 1) (input logic [2:0] a, output logic o);
  if (EN) begin : g
    T v;
    assign v = a;
    assign o = ^v;
  end else begin : h
    assign o = 1'b0;
  end
endmodule
module dut (input logic [2:0] a, output logic o, output logic p);
  child #(.T(pk::w_t)) u (.a(a), .o(o));
  child #(.T(pk::w_t), .EN(0)) u2 (.a(a), .o(p));
endmodule
