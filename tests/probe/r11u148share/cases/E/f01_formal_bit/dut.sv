module top(output logic o);
   function automatic logic f(input logic [3:0] a);
      return a[2];
   endfunction
   assign o = f(4'b0100);
endmodule
