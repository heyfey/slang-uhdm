module top #(parameter int N = 3, parameter type data_t = logic [1:0]) (input data_t [N-1:0] a, output data_t [N-1:0] b, output logic [7:0] c);
   assign b = ~a;
   assign c = 8'(a[N-1]);
endmodule
