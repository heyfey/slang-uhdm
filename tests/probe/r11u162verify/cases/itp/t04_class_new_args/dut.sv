// § initTsEndProgramLocal155
program p;
  class c; int v; function new(int a); v = a; endfunction endclass
  initial begin c h = new(3); $display("%0d", h.v); end
endprogram
