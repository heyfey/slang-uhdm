module top(output logic o);
   parameter logic [3:0] P = 4'b0100;
   function automatic logic f();
      logic t;
      t = P[2];
      return t;
   endfunction
   assign o = f();
endmodule
