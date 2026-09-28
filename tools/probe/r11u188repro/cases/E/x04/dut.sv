// § evalFuncSelectKeepsCall148 (residue decode: const_cast_signext, measurement only)
module top(output logic [11:0] o);
   function automatic logic [11:0] f(input logic [11:0] a);
      return a[11:0];
   endfunction
   assign o = f(12'b0110);
endmodule
