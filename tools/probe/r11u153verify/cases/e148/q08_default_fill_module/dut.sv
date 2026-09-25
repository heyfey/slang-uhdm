// § evalFuncSelectKeepsCall148 § defaultFillImportCopies145
module top(output int o);
   localparam int unsigned V[2] = '{default: 3};
   function automatic int theta();
      return V[1];
   endfunction
   assign o = theta();
endmodule
