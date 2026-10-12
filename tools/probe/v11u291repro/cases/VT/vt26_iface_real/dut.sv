// § tpUseSigBindsTpObj291
interface ifc #(parameter type T = real);
  T d;
endinterface
module dut (output real o);
  ifc u ();
  assign u.d = 1.5;
  assign o = u.d;
endmodule
