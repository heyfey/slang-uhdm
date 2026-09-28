// § evalFuncSelectKeepsCall148 (residue decode: const_cast_signext, measurement only)
module top(output logic [3:0] o);
   function automatic logic [3:0] f(input logic [3:0] a);
      return a;
   endfunction
   assign o = f(4'b0110);
endmodule
