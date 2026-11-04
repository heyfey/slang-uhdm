module top(output logic o);
   function automatic logic theta();
      logic [4:0][1:0] c = 10'h100;
      return c[4][0];
   endfunction
   assign o = theta();
endmodule
