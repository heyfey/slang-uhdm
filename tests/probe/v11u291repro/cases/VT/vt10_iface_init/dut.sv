// § tpUseSigBindsTpObj291
interface ifc #(parameter type T = int unsigned);
  T v = 5;
  T w;
endinterface
module dut (output int unsigned o);
  ifc u ();
  assign u.w = 3;
  assign o = u.v + u.w;
endmodule
