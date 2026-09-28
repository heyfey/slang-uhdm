// § modGenericClassListed196 § modGenericHandleBare196: type and value parameters, a process local
module sub ();
  class box #(type E = int, int N = 2);
    E v [N];
  endclass
  box #(byte, 3) b;
  initial begin
    box #(shortint) c;
    c = new;
  end
endmodule
module top;
  sub v ();
endmodule
