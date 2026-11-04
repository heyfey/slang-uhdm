// § initTsEndProgramLocal155
program p; class C; int x; endclass initial begin C c = new(); C d; d = c; $display("x"); end endprogram
