// § caCallConcatArgFormalTs432
module top(input [63:0] a, output logic [31:0] o);
   typedef logic [31:0] word;
   function automatic word element_sum(input word [1:0] w);
      return w[0] + w[1];
   endfunction
   assign o = element_sum({a[31:0], a[63:32]});
endmodule
