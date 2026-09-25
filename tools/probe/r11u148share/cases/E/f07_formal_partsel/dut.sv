module top(output logic [1:0] o);
   function automatic logic [1:0] f(input logic [3:0] a);
      return a[2:1];
   endfunction
   assign o = f(4'b0110);
endmodule
