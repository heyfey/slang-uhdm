// § tpUseSigBindsTpObj291
package pk; typedef enum logic [1:0] {A, B} e_t; endpackage
interface ifc #(parameter type T = logic);
  T d;
endinterface
module dut (output logic o);
  ifc #(.T(pk::e_t)) u ();
  assign o = ^u.d;
endmodule
