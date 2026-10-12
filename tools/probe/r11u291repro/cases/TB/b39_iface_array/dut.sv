// § tpUseSigBindsTpObj291
interface ifc #(parameter type T = logic [1:0]);
  T d;
endinterface
module dut (output logic o);
  ifc u [2] ();
  assign o = ^u[0].d;
endmodule
