module top(output logic o);
   function automatic logic f();
      logic [3:0] t;
      t = 4'b0100;
      return t[2];
   endfunction
   assign o = f();
endmodule
