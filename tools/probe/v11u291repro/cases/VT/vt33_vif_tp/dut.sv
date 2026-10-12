// § tpUseSigBindsTpObj291
interface ifc; logic d; endinterface
module child #(parameter type T = virtual ifc) (output logic o);
  T h;
  initial o = 1'b0;
endmodule
module dut (output logic o);
  ifc i ();
  child u (.o(o));
endmodule
