// § defPkgStructParamMemberNames154 § tpOvrTypedefStructSpan152
package p; typedef struct packed { logic [3:0] A; } cfg_t; endpackage
interface tif #(parameter p::cfg_t C = '{A: 3}, parameter type T = logic); T s; endinterface
module tb(output logic [3:0] o);
  typedef struct packed { logic [3:0] x; } my_t;
  tif #(.T(my_t)) t();
  assign o = t.s.x;
endmodule
