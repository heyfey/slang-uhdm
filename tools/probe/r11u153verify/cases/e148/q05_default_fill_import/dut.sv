// § evalFuncSelectKeepsCall148 § defaultFillImportCopies145
package pack;
localparam int unsigned V[2] = '{default: 3};
endpackage
module top(output int o);
   import pack::*;
   function automatic int theta();
      return V[0];
   endfunction
   assign o = theta();
endmodule
