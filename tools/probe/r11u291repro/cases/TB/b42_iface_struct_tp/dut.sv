// § tpUseSigBindsTpObj291
typedef struct packed { logic [1:0] a; logic b; } s_t;
interface ifc #(parameter type T = logic);
  T d;
endinterface
module dut (output logic o);
  ifc #(.T(s_t)) u ();
  assign o = ^u.d;
endmodule
