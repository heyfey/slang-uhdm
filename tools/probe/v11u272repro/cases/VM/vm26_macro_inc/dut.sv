// § leftoverTsCopyPerElabUse272
// (no continuous-assignment read of the parameter) macro-born default and builder body from an include in another root file
module kid #(parameter pk::c_t P = `PKC) (output logic [31:0] o);
  localparam int unsigned RD1 = P.d;
  assign o = '0;
endmodule
module dut(output logic [31:0] o);
  kid k0 (.o(o));
endmodule
