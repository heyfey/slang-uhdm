// § tpUseSigBindsTpObj291
package pk; typedef logic [2:0] w_t; endpackage
module child #(parameter type T = logic, parameter int K = 1) (input logic [2:0] a, output logic o);
  case (K)
    1: begin : c1
      T v;
      assign v = a;
      assign o = ^v;
    end
    default: begin : cd
      assign o = 1'b0;
    end
  endcase
endmodule
module dut (input logic [2:0] a, output logic o);
  child #(.T(pk::w_t)) u (.a(a), .o(o));
endmodule
