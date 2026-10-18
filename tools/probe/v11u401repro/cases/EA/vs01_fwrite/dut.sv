// § sysCallEmptyArgIsIntZero401
module top;
  integer f; int a, b;
  initial begin f = 1; $fwrite(f,,a); $write(a,,,b); end
endmodule
