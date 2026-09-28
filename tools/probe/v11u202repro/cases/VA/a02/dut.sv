// § modSpecValueArgSpanAtName202
class c #(int W = 1);
endclass
module sub #(parameter P = 3);
  c #(P) h;
  c #(P+1) h2;
endmodule
module a02;
  sub #(5) u();
  function automatic void f();
    c #(8) z;
  endfunction
endmodule
