// § elabOvArrFoldSharesDefParamTs163
module leaf #(parameter int IFN = 4, parameter logic [IFN-1:0] DAM [2][2] = '{default: '0}) (output logic [IFN-1:0] o);
  assign o = DAM[0][0] ^ DAM[1][1];
endmodule
module top (output logic [3:0] o);
  leaf #(.DAM('{'{4'b1x10, 4'b0001}, '{4'b0010, 4'b0100}})) l(.o(o));
endmodule
