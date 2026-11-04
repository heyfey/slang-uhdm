module top(output logic o);
   parameter logic [3:0] P = 4'b0101;
   function automatic logic theta();
      return P[2];
   endfunction
   assign o = theta();
endmodule
