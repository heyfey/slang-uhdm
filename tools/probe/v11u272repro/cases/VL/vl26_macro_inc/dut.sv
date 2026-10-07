// § leftoverTsCopyPerElabUse272
// macro-born default and builder body from an include in another root file
module kid #(parameter pk::c_t P = `PKC) (output logic [31:0] o);
  assign o = P.d;
endmodule
module dut(output logic [31:0] o);
  kid k0 (.o(o));
endmodule
