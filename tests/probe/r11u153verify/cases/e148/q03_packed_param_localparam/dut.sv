// § evalFuncSelectKeepsCall148
module top(output logic o);
   localparam logic [3:0] X = 4'b1010;
   function automatic logic theta();
      return X[1];
   endfunction
   assign o = theta();
endmodule
