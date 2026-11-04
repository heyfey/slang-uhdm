// § tpUseSigBindsTpObj291
module child #(parameter type IT = int) (output logic o);
  IT a;
  assign o = |a;
endmodule
module dut(output logic o);
  child u (.o(o));
endmodule
