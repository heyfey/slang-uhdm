// § elabOvArrFoldSharesDefParamTs163
module leaf #(parameter int IFN = 4, parameter logic [IFN-1:0] DAM [2] = '{default: '0}) (output logic [IFN-1:0] o);
  assign o = DAM[0] ^ DAM[1];
endmodule
module top (output logic [3:0] o);
  localparam logic [3:0] L0 = 4'b1010;
  leaf #(.DAM('{L0, 4'b0x11})) l(.o(o));
endmodule
