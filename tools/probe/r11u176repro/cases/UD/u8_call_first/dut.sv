// § udpFormNetLvalueFirst176
module ch(A, B, C);
    input [1:0] A, B;
    output [1:0] C;
    assign C = A ^ B;
endmodule
module dut(input [1:0] p, q);
  function automatic [1:0] f(input [1:0] v); return ~v; endfunction
  ch a1(f(p), q, x);
endmodule
