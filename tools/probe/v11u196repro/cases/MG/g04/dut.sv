// § modGenericClassListed196 § modGenericHandleBare196: a generic class in a program with a handle in an initial block and a function formal, two program instances
program sub ();
  class box #(type E = int, int N = 1);
    E v;
  endclass
  function automatic void f(box #(byte, 2) x); endfunction
  initial begin
    box #(shortint, 4) c;
    c = new;
  end
endprogram
module top;
  sub v ();
  sub w ();
endmodule
