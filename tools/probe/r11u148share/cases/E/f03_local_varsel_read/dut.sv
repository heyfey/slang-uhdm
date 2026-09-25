module top(output logic o);
   function automatic logic f();
      logic [1:0][1:0] t;
      t = 4'b0110;
      return t[1][0];
   endfunction
   assign o = f();
endmodule
