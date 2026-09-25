module top(output logic [3:0] o);
   function automatic logic [3:0] f();
      logic [1:0][1:0] t;
      t = '0;
      t[1][0] = 1'b1;
      return t;
   endfunction
   assign o = f();
endmodule
