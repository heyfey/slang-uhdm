// § tpUseGenShadowAbstains291v
package pk; typedef logic [2:0] w_t; endpackage
module child #(parameter type T = logic) (input logic [2:0] a, output logic o);
  if (1) begin : g
    localparam type T = logic [1:0];
    if (1) begin : h
      T v;
      assign v = a[1:0];
      assign o = ^v;
    end
  end
endmodule
module dut (input logic [2:0] a, output logic o);
  child #(.T(pk::w_t)) u (.a(a), .o(o));
endmodule
