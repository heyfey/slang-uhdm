module a1_rgg1;
  function automatic int f_lit();
    int a;
    a  = 0;
    a += 1;
    return a;
  endfunction
  function automatic int f_lit2();
    int b;
    b  = 5;
    b += 3;
    b -= 2;
    b *= 4;
    return b;
  endfunction
  function automatic int f_expl();
    int c;
    c = 0;
    c = c + 1;
    return c;
  endfunction
  function automatic int f_var();
    int d; int e;
    d = 0; e = 2;
    d += e;
    return d;
  endfunction
  function automatic int f_loop();
    int g;
    g = 0;
    while (g < 4) begin
      g += 1;
    end
    return g;
  endfunction
  int h;
  initial begin
    h = 0;
    h += 1;
  end
endmodule
