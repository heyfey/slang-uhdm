module top(output logic [1:0] o);
   parameter logic [3:0] P = 4'b0110;
   function automatic logic [1:0] f();
      return P[1 +: 2];
   endfunction
   assign o = f();
endmodule
